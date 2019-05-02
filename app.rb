require 'sinatra'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'pry'

require_relative 'lib/statement_table_parser.rb'

class Record < ActiveRecord::Base
  validates_presence_of :name, :amount, :performed_at
end

get '/' do
  erb :application
end

get '/records' do
  json Record.all.as_json(except: [:created_at, :updated_at])
end

post '/records' do
  record = Record.new(JSON.parse(request.body.read)['newRecord'])
  if record.save
    halt 200
  else
    halt 400, {'Content-Type' => 'application/json'}, { message: record.errors }.to_json
  end
end

get '/records/report' do
  json Record.group(:name).sum(:amount).to_a
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
