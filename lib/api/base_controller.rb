# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/json'

module Api
  class BaseController < Sinatra::Application
    include Import['services.authorize_request', 'logger']

    LIMIT_SIZE = 30

    set :raise_errors, true

    use Bugsnag::Rack

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
      logger.info params unless ENV['APP_ENV'].eql? 'test'
      pass if request.path.include?('/session') || request.path.include?('/callback')
      @current_user = authorize_request.process request.env['HTTP_AUTHORIZATION'].try(:split, ' ').try(:last)
    rescue JWT::DecodeError, JWT::ExpiredSignature
      halt 401, { 'Content-Type' => 'application/json' }, { message: 'Auth Token is incorrect!' }.to_json
    rescue ActiveRecord::RecordNotFound
      halt 404, { 'Content-Type' => 'application/json' }, { message: 'User not found!' }.to_json
    end
  end
end
