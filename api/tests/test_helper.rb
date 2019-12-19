ENV['APP_ENV'] = 'test'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/reporters'
require 'rack/test'
require 'factory_bot'

require_relative './../api'

def app
  ApiController
end

FactoryBot.definition_file_paths = %w(api/tests/factories)
FactoryBot.find_definitions

include Rack::Test::Methods
include FactoryBot::Syntax::Methods
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]

def authorize
  data = { username: 'username', password: 'password', secure_login: true }.to_json

  post '/session', data, "CONTENT_TYPE" => "application/json"

  JSON.parse(last_response.body)['session_token']
end