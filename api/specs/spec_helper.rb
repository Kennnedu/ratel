require 'rack/test'
require 'rspec'

ENV['APP_ENV'] = 'test'

require_relative './../api_v1'

module RSpecMixin
  include Rack::Test::Methods
  def app(); ApiV1Controller; end
end

# For RSpec 2.x and 3.x
RSpec.configure { |c| c.include RSpecMixin }

RspecApiDocumentation.configure do |config|
  config.app = ApiV1Controller
  config.api_name = "Ratel API"
  config.api_explanation = "An explanation of the API"
  config.format = :json
  config.curl_host = 'http://localhost:3000'
  config.request_headers_to_include = %w[Content-Type Host]
  config.response_headers_to_include = %w[Content-Type Content-Length]
end