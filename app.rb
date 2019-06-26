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

  validates_presence_of :name, :amount, :performed_at
end

class User < ActiveRecord::Base
  has_secure_password
end

class QueryRecord
  attr_reader :relation

  def initialize(relation = Record.all)
    @relation = relation
  end

  def filter(params)
    if params['name'].present?
      query_string = ilike_query_patterns('name', params['name'].split('&')).join(' OR ')
      @relation = @relation.where query_string
    end

    if params['card'].present?
      query_string = ilike_query_patterns('card', params['card'].split('&')).join(' OR ')
      @relation = @relation.where query_string
    end

    if date_from = valid_date?(params['from'])
      @relation = @relation.where('performed_at > ?', date_from + 1.day)
    end

    if date_to = valid_date?(params['to'])
      @relation = @relation.where('performed_at < ?', date_to + 1.day)
    end

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

  def ilike_query_patterns(field, values)
    values.map do |val|
      if val[0].eql? '!'
        "NOT #{field} ILIKE '%#{val[1..-1]}%'"
      else
        "#{field} ILIKE '%#{val}%'"
      end
    end
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
  query_record = QueryRecord.new
                            .belongs_to_user(session['user_id'])
                            .filter(params)
                            .perform_recent.relation
  json records: query_record.as_json(except: [:created_at, :updated_at, :user_id]),
       total_sum: query_record.sum(:amount)
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

get '/records/report' do
  session = auth_user
  json group_by_name: Record.where(user_id: session['user_id']).group(:name).sum(:amount).to_a,
       group_by_card: Record.where(user_id: session['user_id']).group(:card).sum(:amount).to_a
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

post '/session' do
  params = JSON.parse(request.body.read)
  user = User.find_by(username: params['username']) if params['username'].present?

  return halt(400) unless user && user.authenticate(params['password'])
  exp = (DateTime.current + (params['secure_login'] ? 10.minutes : 1.month)).to_i
  response.set_cookie('session_token', value: JWT.encode({ user_id: user.id, exp: exp }, ENV.fetch('SECRET_KEY'), 'HS256'))
  halt 200
end
