require 'sinatra'
require 'sinatra/json'
require 'sinatra/cookies'
require 'sinatra/activerecord'
require 'pry'
require 'jwt'
require 'dotenv'

require_relative 'lib/statement_table_parser.rb'

Dotenv.load

class Record < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :card, required: true

  validates_presence_of :name, :amount, :performed_at
end

class User < ActiveRecord::Base
  has_secure_password
end

class Card < ActiveRecord::Base
  belongs_to :user, required: true

  validates_presence_of :name
end


class QueryRecord
  attr_reader :relation

  def initialize(relation = Record.all)
    @relation = relation
  end

  def filter(params)
    @relation = @relation.joins(:card).includes(:card)

    if params['name'].present?
      include_name_list = params['name'].split('&').reject { |name| name[0].eql? '!' }.map { |name| "%#{name}%" }
      exclude_name_list = params['name'].split('&').select { |name| name[0].eql? '!' }.map { |name| "%#{name[1..-1]}%" }

      if include_name_list.present?
        @relation = @relation.where('name ILIKE ANY (array[?])', include_name_list)
      end

      if exclude_name_list.present?
        exclude_name_list.each { |name|  @relation = @relation.where.not('name ILIKE ?', name) }
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
      @relation = @relation.where('performed_at > ?', date_from + 1.day)
    end

    if date_to = valid_date?(params['to'])
      @relation = @relation.where('performed_at < ?', date_to + 1.day)
    end

    self
  end

  def replenishments_data
    @relation = @relation.where('amount > ?', 0).group(:name).order('sum_amount DESC').sum(:amount)
    self
  end

  def expences_data
    @relation = @relation.where('amount < ?', 0).group(:name).order('sum_amount ASC').sum(:amount)
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
  query_record = QueryRecord.new.belongs_to_user(session['user_id']).filter(params)

  json records: query_record.dup.perform_recent.relation.as_json(except: [:created_at, :updated_at, :user_id, :card_id],
                                                                 include: { card: { only: [:name, :id]}}),
       total_sum: query_record.dup.relation.sum(:amount),
       replenishments_data: query_record.dup.replenishments_data.relation.to_a,
       expences_data: query_record.dup.expences_data.relation.to_a,
       cards_data: query_record.dup.cards_data.relation.to_a
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

post '/records/bulk/parse' do
  auth_user
  parser = StatementTableParser.new(JSON.parse(request.body.read)['html_table'])
  if parser.parse!
    json records: parser.result
  else
    halt 400, {'Content-Type' => 'application/json'}, { message: 'Incorrect format!' }.to_json
  end
end

post '/records/bulk/validate' do
  session = auth_user
  new_records_json = JSON.parse(request.body.read)['records']
  new_records = Array.new(new_records_json.size) { Record.new(user_id: session['user_id'] ) }
  new_records.each_with_index { |record, index| record.assign_attributes(new_records_json[index]) }
  unless new_records.map(&:valid?).include?(false)
    json records: new_records_json
  else
    halt 400,
      {'Content-Type' => 'application/json'},
      { message: new_records.map(&:errors).map(&:full_messages).map { |m| m.join(', ') } }.to_json
  end
end

post '/records/bulk' do
  session = auth_user
  new_records_json = JSON.parse(request.body.read)['records']
  saved_records = new_records_json.map { |record| Record.find_or_create_by(record.merge(user_id: session['user_id'])) }
  unless saved_records.map(&:valid?).include?(false)
    halt 200
  else
    halt 400,
      {'Content-Type' => 'application/json'},
      { message: saved_records.map(&:errors).map(&:full_messages).map { |m| m.join(', ') } }.to_json
  end
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

post '/session' do
  params = JSON.parse(request.body.read)
  user = User.find_by(username: params['username']) if params['username'].present?

  return halt(400) unless user && user.authenticate(params['password'])
  exp = (DateTime.current + (params['secure_login'] ? 10.minutes : 1.month)).to_i
  response.set_cookie('session_token', value: JWT.encode({ user_id: user.id, exp: exp }, ENV.fetch('SECRET_KEY'), 'HS256'))
  halt 200
end
