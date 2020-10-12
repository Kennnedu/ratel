# frozen_string_literal: true

resource 'Session' do
  let(:user) { create :user, password: 'password' }

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  post '/sessions' do
    context 'status 200' do
      let(:raw_post) { { username: user.username, password: user.password, secure_login: true }.to_json }

      example_request 'Create' do
        expect(status).to eq 200
        expect(JSON.parse(response_body).keys).to include 'session_token'
      end
    end

    context 'status 400' do
      let(:raw_post) { { username: user.username, password: '111', secure_login: true }.to_json }

      example_request 'Create validation error' do
        expect(status).to eq 400
        expect(response_body).to eq({ message: 'Username or Password is incorrect!' }.to_json)
      end
    end
  end
end
