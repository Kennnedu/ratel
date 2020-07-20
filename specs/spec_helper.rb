# frozen_string_literal: true

require 'rack/test'
require 'rspec'
require 'rspec_api_documentation/dsl'
require 'factory_bot'
require 'database_cleaner/active_record'

ENV['APP_ENV'] = 'test'

require_relative './../api'

module RSpecMixin
  include Rack::Test::Methods
  def app
    ApiController
  end
end

FactoryBot.definition_file_paths = %w[api/specs/factories]
DatabaseCleaner.strategy = :truncation

# For RSpec 2.x and 3.x
RSpec.configure do |config|
  config.include RSpecMixin
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
    DatabaseCleaner.clean
  end
end

RspecApiDocumentation.configure do |config|
  config.app = ApiController
  config.api_name = 'Ratel API'
  config.api_explanation = 'An explanation of the API'
  config.format = :json
  config.curl_host = 'http://localhost:4567'
  config.request_headers_to_include = %w[Content-Type Host Authorization]
  config.response_headers_to_include = %w[Content-Type Content-Length]
end
