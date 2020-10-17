# frozen_string_literal: true

require_relative './base_api_controller'

class SessionsController < BaseApiController
  post '/' do
    token = CreateSession.new.process(JSON.parse(request.body.read)&.transform_keys(&:to_sym))
    return json(session_token: token) if token

    halt 400, { 'Content-Type' => 'application/json' }, { message: 'Username or Password is incorrect!' }.to_json
  rescue KeyError, ArgumentError
    halt 400, { 'Content-Type' => 'application/json' }, { message: 'Username or Password can\'t be blank!' }.to_json
  end
end
