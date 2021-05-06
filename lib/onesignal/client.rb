require 'json'

module Onesignal
  class Client
    BASE_URL = 'https://onesignal.com/api/v1/'.freeze

    def initialize
      super
      @connection = Faraday.new(BASE_URL)
      @api_token = ENV.fetch('ONESIGNAL_API_TOKEN', '')
      @app_id = ENV.fetch('ONESIGNAL_APP_ID', '')
    end

    def create_notification(user_id, message, data={})
      do_call(
        'notifications',
        {
          "contents" => { "en" => message },
          "channel_for_external_user_ids" => "push",
          "include_external_user_ids" => [user_id],
          "data" => data
        }
      )
    end

    private

    def do_call(path, request_body = nil)
      response = @connection.post do |request|
        request.url(path)
        request.headers['Content-Type'] = 'application/json;charset=utf-8'
        request.headers['Authorization'] = "Basic #{@api_token}"
        body = { app_id: @app_id }
        body = body.merge(request_body).to_json if request_body
        yield body if block_given?
        request.body = body
      end

      JSON.parse(response.body)
    end
  end
end

