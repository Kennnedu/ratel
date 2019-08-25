require 'sinatra'
require 'sinatra/json'
require 'sinatra/cookies'
require 'sinatra/activerecord'
require 'byebug'
require 'jwt'
require 'dotenv'

require_relative 'lib/statement_table_parser.rb'

Dotenv.load

class Record < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :card, required: true
  has_many :records_tags, dependent: :destroy
  has_many :tags, through: :records_tags

  # validates :name, :amount, :performed_at, :user_id, uniqueness: true, presence: true

  accepts_nested_attributes_for :records_tags, allow_destroy: true

  def as_json
    result = super(except: [:created_at, :updated_at, :user_id, :card_id],
                   include: { card: { only: [:name, :id]},
                              records_tags: { only: [:id, :tag_id],
                                              include: { tag: { only: [:id, :name]}}}})
    return result if card
    result.merge(card: Card.new(id: 0, name: '').as_json(only: [:name, :id]))
  end
end

class Tag < ActiveRecord::Base
  belongs_to :user, required: true
  has_many :records_tags, dependent: :destroy
  has_many :records, through: :records_tags

  # validates :name, :user_id, uniqueness: true, presence: true
end

class RecordsTag < ActiveRecord::Base
  belongs_to :record
  belongs_to :tag
end

class User < ActiveRecord::Base
  has_secure_password
end

class Card < ActiveRecord::Base
  belongs_to :user, required: true

  validates_presence_of :name
end

class RecordQuery
  attr_reader :relation

  def initialize(relation = Record.all)
    @relation = relation
  end

  def filter(params)
    @relation = @relation.left_joins(:card).includes(:card, records_tags: [:tag])

    if params['name'].present?
      include_name_list = params['name'].split('&').reject { |name| name[0].eql? '!' }.map { |name| "%#{name}%" }
      exclude_name_list = params['name'].split('&').select { |name| name[0].eql? '!' }.map { |name| "%#{name[1..-1]}%" }

      if include_name_list.present?
        @relation = @relation.where('records.name ILIKE ANY (array[?])', include_name_list)
      end

      if exclude_name_list.present?
        exclude_name_list.each { |name|  @relation = @relation.where.not('records.name ILIKE ?', name) }
      end
    end

    if params['card'].present?
      include_card_list = params['card'].split('&').reject { |card| card.eql? '!' }.map { |card| "%#{card}%" }
      exclude_card_list = params['card'].split('&').select { |card| card.eql? '!' }.map { |card| "%#{card[1..-1]}%" }

      if include_card_list.present?
        @relation = @relation.where('cards.name ILIKE ANY (array[?])', include_card_list)
      end

      if exclude_card_list.present?
        exclude_card_list.each { |card| @relation = @relation.where.not('cards.name ILIKE ?', card) }
      end
    end

    if date_from = valid_date?(params['from'])
      @relation = @relation.where('records.performed_at > ?', date_from + 1.day)
    end

    if date_to = valid_date?(params['to'])
      @relation = @relation.where('records.performed_at < ?', date_to + 1.day)
    end

    self
  end

  def dashboard_table_data(table)
    case table
    when 'cards'
      cards_data
    when 'replenishments'
      replenishments_data
    when 'expenses'
      expenses_data
    when 'tags'
      tags_data
    else
      self
    end
  end

  def tags_data
    @relation = @relation.joins(:tags).group('tags.name').order('sum_amount DESC').sum(:amount)
    self
  end

  def replenishments_data
    @relation = @relation.where('records.amount > ?', 0).group(:name).order('sum_amount DESC').sum(:amount)
    self
  end

  def expenses_data
    @relation = @relation.where('records.amount < ?', 0).group(:name).order('sum_amount ASC').sum(:amount)
    self
  end

  def cards_data
    @relation = @relation.group('cards.name').order('sum_amount DESC').sum(:amount)
    self
  end

  def belongs_to_user(user_id)
    @relation = @relation.where(user_id: user_id) if user_id.present?
    self
  end

  def perform_recent
    @relation = @relation.order(performed_at: :desc)
    self
  end

  private

  def valid_date?(date_string)
    Date.parse(date_string)
  rescue
    nil
  end
end

def auth_user
  JWT.decode(request.cookies['session_token'], ENV.fetch('SECRET_KEY'), true, { algorithm: 'HS256' }).first
rescue JWT::DecodeError, JWT::ExpiredSignature
  halt 401
end

get '/' do
  erb :application
end

get '/records' do
  session = auth_user
  query_record = RecordQuery.new.belongs_to_user(session['user_id']).filter(params)

  json records: query_record.dup.perform_recent.relation.as_json,
       total_sum: query_record.dup.relation.sum(:amount)
end

get '/dashboard' do
  session = auth_user
  dashboard_table_data = RecordQuery.new.belongs_to_user(session['user_id']).filter(params)
                                    .dashboard_table_data(params['dasboard_table'])

  json dashboard_table: dashboard_table_data.relation.to_a
end

post '/records' do
  session = auth_user
  record = Record.new(JSON.parse(request.body.read)['record'].merge(user_id: session['user_id']))
  if record.save
    halt 200
  else
    halt 400, {'Content-Type' => 'application/json'}, { message: record.errors }.to_json
  end
end

post '/records/bulk' do
  session = auth_user

  parser = StatementTableParser.new(JSON.parse(request.body.read)['html_table'])

  halt(400, {'Content-Type' => 'application/json'}, { message: 'Incorrect format!' }.to_json) unless parser.parse!

  saved_records = parser.result.map do |record|
    card = Card.find_or_create_by(name: record['card'], user_id: session['user_id'])
    record.delete :card
    Record.find_or_create_by(record.merge(user_id: session['user_id'], card: card))
  end

  unless saved_records.map(&:valid?).include?(false)
    halt 200
  else
    halt 400,
      {'Content-Type' => 'application/json'},
      { message: saved_records.map(&:errors).map(&:full_messages).map { |m| m.join(', ') } }.to_json
  end
end

put '/records/batch' do
  session = auth_user

  filtered_records = RecordQuery.new.belongs_to_user(session['user_id']).filter(params).relation

  filtered_records.each { |record| record.update(params['batch_form']) } if params['batch_form']

  if params['removing_tag_ids']
    RecordsTag.where(record_id: filtered_records.map(&:id), tag_id: params['removing_tag_ids']).destroy_all
  end

  halt 200
end

put '/records/:id' do |id|
  auth_user
  updating_attributes = JSON.parse(request.body.read)['record']
  record = Record.find(id)
  if record.update(updating_attributes)
    halt 200
  else
    halt 400, {'Content-Type' => 'application/json'}, { message: record.errors }.to_json
  end
end

delete '/records/batch' do
  session = auth_user
  
  RecordQuery.new.belongs_to_user(session['user_id']).filter(params).relation.destroy_all
  
  halt 200
end

delete '/records/:id' do |id|
  auth_user
  record = Record.find(id)
  if record.delete
    halt 200
  else
    halt 400
  end
end

get '/cards' do
  session = auth_user

  json cards: Card.where(user_id: session['user_id']).as_json(except: [:updated_at, :created_at, :user_id])
end

post '/cards' do
  session = auth_user
  card = Card.new(JSON.parse(request.body.read)['card'].merge(user_id: session['user_id']))
  if card.save
    halt 200
  else
    halt 400, {'Content-Type' => 'application/json'}, { message: card.errors }.to_json
  end
end

put '/cards/:id' do |id|
  session = auth_user
  updating_attributes = JSON.parse(request.body.read)['card']
  card = Card.find_by(id: id, user_id: session['user_id'])
  if card.update(updating_attributes)
    halt 200
  else
    halt 400, {'Content-Type' => 'application/json'}, { message: card.errors }.to_json
  end
end

delete '/cards/:id' do |id|
  session = auth_user

  card = Card.find_by(id: id, user_id: session['user_id'])
  if card.delete
    halt 200
  else
    halt 400
  end
end

get '/tags' do
  session = auth_user

  json tags: Tag.where(user_id: session['user_id']).as_json(except: [:updated_at, :created_at])
end

post '/tags/:name' do |name|
  session = auth_user

  tag = Tag.find_or_create_by(name: name, user_id: session['user_id'])
  if tag.errors.empty?
    json tag: tag.as_json(except: [:updated_at, :created_at])
  else
    halt 400, {'Content-Type' => 'application/json'}, { message: tag.errors }.to_json
  end
end

post '/session' do
  params = JSON.parse(request.body.read)
  user = User.find_by(username: params['username']) if params['username'].present?

  return halt(400) unless user && user.authenticate(params['password'])
  exp = (DateTime.current + (params['secure_login'] ? 10.minutes : 1.month)).to_i
  response.set_cookie('session_token', value: JWT.encode({ user_id: user.id, exp: exp }, ENV.fetch('SECRET_KEY'), 'HS256'))
  halt 200
end
