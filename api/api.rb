require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/cookies'
require 'sinatra/activerecord'
require 'jwt'
require 'dotenv'

require_relative '../lib/statement_parsers_factory.rb'

Dotenv.load

Dir["./api/models/*.rb"].each { |file| require file }

class SessionController < Sinatra::Application
  post '/session' do
    params = JSON.parse(request.body.read)
    user = User.find_by(username: params['username']) if params['username'].present?

    return halt(400) unless user && user.authenticate(params['password'])
    exp = (DateTime.current + (params['secure_login'] ? 10.minutes : 1.month)).to_i
    json session_token: JWT.encode({ user_id: user.id, exp: exp }, ENV.fetch('SECRET_KEY'), 'HS256')
  end
end

class ApiController < Sinatra::Application
  use SessionController

  before do
    auth_token = request.env['HTTP_AUTHORIZATION'].split(' ').last
    @session = JWT.decode(auth_token, ENV.fetch('SECRET_KEY'), true, { algorithm: 'HS256' }).first
  rescue JWT::DecodeError, JWT::ExpiredSignature
    halt 401
  end

  get '/records' do
    query_record = RecordQuery.new.belongs_to_user(@session['user_id']).filter(params)

    resp = if params[:offset]
            {
              records: query_record.dup.perform_recent.preload_ref.relation.offset(params[:offset]).limit(params[:limit] || 30).as_json
            }
          else
            {
              records: query_record.dup.perform_recent.preload_ref.relation.limit(params[:limit] || 30).as_json,
              total_sum: query_record.dup.relation.sum(:amount),
              total_count: query_record.dup.relation.count
            }
          end

    json resp
  end

  get '/records/names' do
    json record_names: Record.select(:name).distinct
                            .where(user_id: @session['user_id'])
                            .where('name ILIKE ?', "%#{params[:keyword]}%")
                            .limit(30)
                            .pluck(:name)
  end

  get '/dashboard' do
    dashboard_table_data = RecordQuery.new.belongs_to_user(@session['user_id']).filter(params)
                                      .dashboard_table_data(params['dasboard_table'])

    json dashboard_table: dashboard_table_data.relation.to_a
  end

  post '/records' do
    record = Record.new(JSON.parse(request.body.read)['record'].merge(user_id: @session['user_id']))

    return halt(200) if record.save
    halt 400, {'Content-Type' => 'application/json'}, { message: record.errors }.to_json
  end

  post '/records/bulk' do
    parser = StatementParsersFactory.get_parser params['html_file']['tempfile'].read

    halt(400, {'Content-Type' => 'application/json'}, { message: 'Incorrect format!' }.to_json) unless parser.parse!

    saved_records = parser.result.map do |record|
      card = Card.find_or_create_by(name: record['card'], user_id: @session['user_id'])
      record.delete :card
      Record.find_or_create_by(record.merge(user_id: @session['user_id'], card: card))
    end

    return halt(200) unless saved_records.map(&:valid?).include?(false)
    halt 400,
      {'Content-Type' => 'application/json'},
      { message: saved_records.map(&:errors).map(&:full_messages).map { |m| m.join(', ') } }.to_json
  end

  put '/records/batch' do
    filtered_records = RecordQuery.new.belongs_to_user(@session['user_id']).filter(params).relation

    filtered_records.each { |record| record.update(params['batch_form']) } if params['batch_form']

    if params['removing_tag_ids']
      RecordsTag.where(record_id: filtered_records.map(&:id), tag_id: params['removing_tag_ids']).destroy_all
    end

    halt 200
  end

  put '/records/:id' do |id|
    updating_attributes = JSON.parse(request.body.read)['record']
    record = Record.find(id)

    return halt(200) if record.update(updating_attributes)
    halt 400, {'Content-Type' => 'application/json'}, { message: record.errors }.to_json
  end

  delete '/records/batch' do
    RecordQuery.new.belongs_to_user(@session['user_id']).filter(params).relation.destroy_all

    halt 200
  end

  delete '/records/:id' do |id|
    record = Record.find(id)

    halt record.delete ? 200 : 400
  end

  get '/cards' do
    json cards: Card.where(user_id: @session['user_id']).as_json(except: [:updated_at, :created_at, :user_id])
  end

  post '/cards' do
    card = Card.new(JSON.parse(request.body.read)['card'].merge(user_id: @session['user_id']))

    return halt(200) if card.save
    halt 400, {'Content-Type' => 'application/json'}, { message: card.errors }.to_json
  end

  put '/cards/:id' do |id|
    updating_attributes = JSON.parse(request.body.read)['card']
    card = Card.find_by(id: id, user_id: @session['user_id'])

    return halt(200) if card.update(updating_attributes)
    halt 400, {'Content-Type' => 'application/json'}, { message: card.errors }.to_json
  end

  delete '/cards/:id' do |id|
    card = Card.find_by(id: id, user_id: @session['user_id'])

    halt card.delete ? 200 : 400
  end

  get '/tags' do
    json tags: Tag.where(user_id: @session['user_id'])
                  .where('name ILIKE ?', "%#{params[:keyword]}%")
                  .as_json(except: [:updated_at, :created_at])
  end

  post '/tags/:name' do |name|
    tag = Tag.find_or_create_by(name: name, user_id: @session['user_id'])

    return json(tag: tag.as_json(except: [:updated_at, :created_at])) if tag.errors.empty?
    halt 400, {'Content-Type' => 'application/json'}, { message: tag.errors }.to_json
  end
end
