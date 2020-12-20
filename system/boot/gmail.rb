# frozen_string_literal: true

Container.boot(:gmail) do
  init do
    require 'google/apis/gmail_v1'
    require 'googleauth'
    require 'googleauth/stores/redis_token_store'
  end

  start do
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
    SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

    client_id = Google::Auth::ClientId.new ENV.fetch('GMAIL_CLIENT_ID', ''), ENV.fetch('GMAIL_CLIENT_SECRET', '')
    token_store = Google::Auth::Stores::RedisTokenStore.new redis: Redis.new

    register(:google_auth, Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store, '/oauth2/gmail/callback'))

    gmail_api = Google::Apis::GmailV1::GmailService.new
    gmail_api.client_options.application_name = 'Ratel'

    register(:gmail_api, gmail_api)
  end
end
