require 'sinatra'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'pry'

require_relative 'lib/statement_table_parser.rb'

class Record < ActiveRecord::Base
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
    @relation = @relation.where("name ILIKE ANY (array[?])", params['name'].split('&').map { |c| "%#{c}%" }) if params['name'].present?
    @relation = @relation.where("card ILIKE ANY (array[?])", params['card'].split('&').map { |c| "%#{c}%" }) if params['card'].present?

    if date_from = valid_date?(params['from'])
      @relation = @relation.where('performed_at > ?', date_from + 1.day)
    end

    if date_to = valid_date?(params['to'])
      @relation = @relation.where('performed_at < ?', date_to + 1.day)
    end

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

get '/' do
  erb :application
end

get '/records' do
  query_record = QueryRecord.new.filter(params).perform_recent.relation
  json records: query_record.as_json(except: [:created_at, :updated_at]),
       total_sum: query_record.sum(:amount)
end

post '/records' do
  record = Record.new(JSON.parse(request.body.read)['record'])
  if record.save
    halt 200
  else
    halt 400, {'Content-Type' => 'application/json'}, { message: record.errors }.to_json
  end
end

get '/records/report' do
  json group_by_name: Record.group(:name).sum(:amount).to_a,
       group_by_card: Record.group(:card).sum(:amount).to_a
end

post '/records/bulk/parse' do
  parser = StatementTableParser.new(JSON.parse(request.body.read)['html_table'])
  if parser.parse!
    json records: parser.result
  else
    halt 400, {'Content-Type' => 'application/json'}, { message: 'Incorrect format!' }.to_json
  end
end

post '/records/bulk/validate' do
  new_records_json = JSON.parse(request.body.read)['records']
  new_records = Array.new(new_records_json.size) { Record.new }
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
  new_records_json = JSON.parse(request.body.read)['records']
  saved_records = new_records_json.map { |record| Record.find_or_create_by(record) }
  unless saved_records.map(&:valid?).include?(false)
    halt 200
  else
    halt 400,
      {'Content-Type' => 'application/json'},
      { message: saved_records.map(&:errors).map(&:full_messages).map { |m| m.join(', ') } }.to_json
  end
end

put '/records/:id' do |id|
  updating_attributes = JSON.parse(request.body.read)['record']
  record = Record.find(id)
  if record.update(updating_attributes)
    halt 200
  else
    halt 400, {'Content-Type' => 'application/json'}, { message: record.errors }.to_json
  end
end

delete '/records/:id' do |id|
  record = Record.find(id)
  if record.delete
    halt 200
  else
    halt 400
  end
end
