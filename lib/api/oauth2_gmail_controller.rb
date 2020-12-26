# frozen_string_literal: true

require 'api/base_controller'

module Api
  class Oauth2GmailController < BaseController
    include Import['google_auth']

    get '/' do
      unless @current_user.gmail_connection
        halt 404, { 'Content-Type' => 'application/json' }, { message: 'Gmail connection not found!' }.to_json
      end

      state = { redirect_url: params[:redirect_url], user_id: @current_user.gmail_connection.id.to_s }.to_json
      url = google_auth.get_authorization_url(base_url: request.url, state: state)
      json url: url
    end

    get '/callback' do
      state = JSON.parse params[:state]

      credentials = google_auth.get_and_store_credentials_from_code(
        user_id: state['user_id'], code: params['code'], base_url: request.url
      )

      GmailConnection.find(state['user_id']).update_attribute('connected', true) if credentials

      redirect state['redirect_url'] || '/'
    end
  end
end
