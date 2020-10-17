# frozen_string_literal: true

require_relative '../application'

require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/cookies'

class BaseApiController < Sinatra::Application
  LIMIT_SIZE = 30

  attr_reader :authorize_request

  def initialize
    super
    @authorize_request = Container['services.authorize_request']
  end

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
    @current_user = authorize_request.process request.env['HTTP_AUTHORIZATION'].try(:split, ' ').try(:last)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    halt 401, { 'Content-Type' => 'application/json' }, { message: 'Auth Token is incorrect!' }.to_json
  rescue ActiveRecord::RecordNotFound
    halt 404, { 'Content-Type' => 'application/json' }, { message: 'User not found!' }.to_json
  end
end
