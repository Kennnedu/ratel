require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/cookies'
require 'sinatra/activerecord'
require 'jwt'
require 'dotenv'
require_relative '../lib/statement_parsers_factory.rb'

Dotenv.load

Dir["./api/models/*.rb"].each { |file| require file }

class ApiV1Controller < Sinatra::Application
  before do
    content_type :json
    headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'OPTIONS, GET, POST, DELETE, PUT',
            'Access-Control-Allow-Headers' => 'X-Requested-With, Content-Type, Accept, Origin, Authorization'
    halt 200 if request.request_method.eql?('OPTIONS')
  end

  before do
    pass if request.path.include?('/session')
    auth_token = request.env['HTTP_AUTHORIZATION'].try(:split, ' ').try(:last)
    @session = JWT.decode(auth_token, ENV.fetch('SECRET_KEY'), true, { algorithm: 'HS256' }).first
  rescue JWT::DecodeError, JWT::ExpiredSignature
    halt 401
  end

  post '/session' do
    params = JSON.parse(request.body.read)
    user = User.find_by(username: params['username']) if params['username'].present?

    return halt(400) unless user && user.authenticate(params['password'])
    exp = (DateTime.current + (params['secure_login'] ? 10.minutes : 1.month)).to_i
    json session_token: JWT.encode({ user_id: user.id, exp: exp }, ENV.fetch('SECRET_KEY'), 'HS256')
  end

  get '/records' do
    offset = params['offset'].to_i
    limit = params['limit'].to_i.zero? ? 30 : params['limit'].to_i

    query_record = RecordQuery.new.belongs_to_user(@session['user_id']).filter(params)

    json records: query_record.dup.order(params).preload_ref.relation.offset(offset).limit(limit).map(&:as_json_records),
         offset: offset,
         limit: limit,
         total_count: query_record.dup.relation.count
  end

  get '/records/sum' do
    json sum: RecordQuery.new.belongs_to_user(@session['user_id']).filter(params).relation.sum('records.amount')
  end

  get '/records/names' do
    offset = params['offset'].to_i
    limit = params['limit'].to_i.zero? ? 30 : params['limit'].to_i

    record_query = RecordQuery.new.belongs_to_user(@session['user_id']).filter(params['record'] || {})
                    .relation.select('records.name').group('records.name')

    record_names_query = RecordNameQuery.new(record_query).belongs_to_user(@session['user_id']).filter(params).order(params).relation

    json record_names: record_names_query.dup.offset(offset).limit(limit).as_json(except: :id),
         offset: offset,
         limit: limit,
         total_count: Record.from(record_names_query.dup).count
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

  put '/records' do
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

  delete '/records' do
    RecordQuery.new.belongs_to_user(@session['user_id']).filter(params).relation.destroy_all

    halt 200
  end

  delete '/records/:id' do |id|
    record = Record.find(id)

    halt record.delete ? 200 : 400
  end

  get '/cards' do
    json cards: CardQuery.new.belongs_to_user(@session['user_id']).filter(@session['user_id'], params).order(params).relation.as_json
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
    json tags: TagQuery.new.belongs_to_user(@session['user_id']).filter(@session['user_id'], params).order(params).relation.as_json                                 
  end

  post '/tags/:name' do |name|
    tag = Tag.find_or_create_by(name: name, user_id: @session['user_id'])

    return json(tag: tag.as_json(except: [:updated_at, :created_at])) if tag.errors.empty?
    halt 400, {'Content-Type' => 'application/json'}, { message: tag.errors }.to_json
  end

  post '/tags' do
    tag = Tag.new(JSON.parse(request.body.read)['tag'].merge(user_id: @session['user_id']))

    return halt(200) if tag.save
    halt 400, {'Content-Type' => 'application/json'}, { message: tag.errors }.to_json
  end

  put '/tags/:id' do |id|
    updating_attributes = JSON.parse(request.body.read)['tag']
    tag = Tag.find_by(id: id, user_id: @session['user_id'])

    return halt(200) if tag.update(updating_attributes)
    halt 400, {'Content-Type' => 'application/json'}, { message: tag.errors }.to_json
  end

  delete '/tags/:id' do |id|
    tag = Tag.find_by(id: id, user_id: @session['user_id'])

    halt tag.destroy ? 200 : 400
  end
end
