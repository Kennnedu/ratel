# frozen_string_literal: true

require_relative '../application'

require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/cookies'

class ApiController < Sinatra::Application
  LIMIT_SIZE = 30

  def paginate(query, params)
    @offset = params['offset'].to_i
    @limit = params['limit'].to_i.zero? ? LIMIT_SIZE : params['limit'].to_i
    @total = query.klass.from(query).count
    query.dup.limit(@limit).offset(@offset)
  end

  def crud_response(resource)
    if resource.nil?
      halt 404, { 'Content-Type' => 'application/json' }, { message: 'Not found' }.to_json
    elsif resource.errors.presence
      halt 400, { 'Content-Type' => 'application/json' }, { message: resource.errors.messages }.to_json
    else
      json resource.as_json
    end
  end

  before do
    content_type 'application/json'
    headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'OPTIONS, GET, POST, DELETE, PUT',
            'Access-Control-Allow-Headers' => 'X-Requested-With, Content-Type, Accept, Origin, Authorization'
    halt 200 if request.request_method.eql?('OPTIONS')
  end

  before do
    pass if request.path.include?('/session')
    @current_user = AuthorizeRequest.new(request.env['HTTP_AUTHORIZATION'].try(:split, ' ').try(:last)).process
  rescue JWT::DecodeError, JWT::ExpiredSignature
    halt 401, { 'Content-Type' => 'application/json' }, { message: 'Auth Token is incorrect!' }.to_json
  rescue ActiveRecord::RecordNotFound
    halt 404, { 'Content-Type' => 'application/json' }, { message: 'User not found!' }.to_json
  end

  post '/session' do
    token = CreateSession.new(JSON.parse(request.body.read)).process
    return json(session_token: token) if token

    halt 400, { 'Content-Type' => 'application/json' }, { message: 'Username or Password is incorrect!' }.to_json
  rescue KeyError
    halt 400, { 'Content-Type' => 'application/json' }, { message: 'Username or Password can\'t be blank!' }.to_json
  end

  get '/records' do
    json records: paginate(
      FindRecords.new(@current_user.records.includes(:card, records_tags: [:tag])).call(params)
    ).as_json,
         offset: @offset,
         limit: @limit,
         total_count: @total
  end

  get '/records/sum' do
    json sum: Record.from(
      FindRecords.new(@current_user.records).call(params).distinct.select(:id, :amount).reorder(:amount),
      'names'
    ).sum('names.amount')
  end

  get '/records/names' do
    json record_names: paginate(
      FindRecordNames.new(
        FindRecords.new(@current_user.records).call(params['record']).select('records.name').group('records.name')
        .reorder('records.name asc')
      ).call(params)
    ).as_json(except: :id, include: {}),
         offset: @offset,
         limit: @limit,
         total_count: @total
  end

  post '/records' do
    crud_response(
      CreateResource.new(Record, JSON.parse(request.body.read)['record'].merge(user_id: @current_user.id)).process
    )
  end

  post '/records/bulk' do
    parser = StatementParsersFactory.new_parser params['html_file']['tempfile'].read

    halt(400, { 'Content-Type' => 'application/json' }, { message: 'Incorrect format!' }.to_json) unless parser.parse!

    saved_records = parser.result.map do |record|
      card = Card.find_or_create_by(name: record['card'], user_id: @current_user.id)
      record.delete :card
      Record.find_or_create_by(record.merge(user_id: @current_user.id, card: card))
    end

    return halt(200) unless saved_records.map(&:valid?).include?(false)

    halt 400,
         { 'Content-Type' => 'application/json' },
         { message: saved_records.map(&:errors).map(&:full_messages).map { |m| m.join(', ') } }.to_json
  end

  put '/records' do
    UpdateBulkRecord.new(
      FindRecords.new(@current_user.records).call(params),
      params['batch_form'],
      params['removing_tag_ids']
    ).process

    halt 200
  end

  put '/records/:id' do |id|
    crud_response(
      UpdateResource.new(
        Record.find_by(id: id, user: @current_user),
        JSON.parse(request.body.read)['record']
      ).process
    )
  end

  delete '/records' do
    FindRecords.new(@current_user.records).call(params).destroy_all
    halt 200
  end

  delete '/records/:id' do |id|
    crud_response Record.find_by(id: id)&.destroy
  end

  get '/cards' do
    json cards: FindCards.new(@current_user.cards).call(params, @current_user).as_json
  end

  post '/cards' do
    crud_response(
      CreateResource.new(@current_user.cards, JSON.parse(request.body.read)['card']).process
    )
  end

  put '/cards/:id' do |id|
    crud_response(
      UpdateResource.new(
        Card.find_by(id: id, user_id: @current_user.id),
        JSON.parse(request.body.read)['card']
      ).process
    )
  end

  delete '/cards/:id' do |id|
    crud_response Card.find_by(id: id, user_id: @current_user.id)&.destroy
  end

  get '/tags' do
    json tags: FindTags.new(@current_user.tags).call(params, @current_user).as_json
  end

  post '/tags/:name' do |name|
    tag = Tag.find_or_create_by(name: name, user_id: @current_user.id)

    return json(tag: tag.as_json(except: %i[updated_at created_at])) if tag.errors.empty?

    halt 400, { 'Content-Type' => 'application/json' }, { message: tag.errors }.to_json
  end

  post '/tags' do
    crud_response(
      CreateResource.new(Tag, JSON.parse(request.body.read)['tag'].merge(user_id: @current_user.id)).process
    )
  end

  put '/tags/:id' do |id|
    crud_response(
      UpdateResource.new(Tag.find_by(id: id, user_id: @current_user.id), JSON.parse(request.body.read)['tag']).process
    )
  end

  delete '/tags/:id' do |id|
    crud_response Tag.find_by(id: id)&.destroy
  end
end
