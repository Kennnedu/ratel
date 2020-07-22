# frozen_string_literal: true

require_relative '../spec_helper'

resource 'Session' do
  let(:user) { create :user, password: 'password' }

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  post '/session' do
    let(:raw_post) { { username: user.username, password: user.password, secure_login: true }.to_json }

    example_request 'login' do
      expect(status).to eq 200
    end
  end
end
