require_relative './../test_helper'

describe 'Session' do
  describe 'POST /session' do
    before { authorize }

    it { assert_equal last_response.status, 200 }
    it { assert_equal JSON.parse(last_response.body)['session_token'].present?, true }
  end

  describe 'POST /session' do
    before do
      data = { username: 'username', password: '', secure_login: true}.to_json

      post '/session', data, "CONTENT_TYPE" => "application/json"
    end

    it { assert_equal last_response.status, 400 }
    it { assert_empty last_response.body }
  end
end