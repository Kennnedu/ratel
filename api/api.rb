# frozen_string_literal: true

require_relative '../application'

require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/cookies'

class ApiController < Sinatra::Application
  LIMIT_SIZE = 30

  def paginate(query)
    set_paginate_vars
    @total = query.klass.from(query).count
    query.dup.limit(@limit).offset(@offset)
  end

  def set_paginate_vars
    @offset = params['offset'].to_i
    @limit = params['limit'].to_i.zero? ? LIMIT_SIZE : params['limit'].to_i
  end

  def crud_response(resource)
    if resource.nil?
      halt 404, { 'Content-Type' => 'application/json' }, { message: 'Not found' }.to_json
    elsif resource.errors.presence
      halt 400, { 'Content-Type' => 'application/json' }, { message: resource.errors.full_messages }.to_json
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
        FindRecords.new(@current_user.records).call(params['record'] || {}).select('records.name').group('records.name')
          .unscope(:order)
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
    CreateBulkRecord.new(@current_user, params['html_file']['tempfile'].read).process
    halt 200
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
    json cards: FindCards.new(@current_user.cards).call(@current_user, params).as_json
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
    json tags: FindTags.new(@current_user.tags).call(@current_user, params).as_json
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
    crud_response Tag.find_by(id: id, user_id: @current_user.id)&.destroy
  end

  get '/reports' do
    json reports: paginate(
      Report.all.order(created_at: :desc)
    ).as_json,
         offset: @offset,
         limit: @limit,
         total_count: @total
  end

  post '/reports' do
    crud_response CreateResource.new(Report, params.merge(user_id: @current_user.id)).process
  end

  delete '/reports/:id' do |id|
    crud_response Report.find_by(id: id, user_id: @current_user.id)&.destroy
  end
end
