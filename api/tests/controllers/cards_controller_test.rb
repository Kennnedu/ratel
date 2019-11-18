require_relative './../test_helper'

describe 'Cards' do
  before do
    token = authorize
    header('Authorization', "Bearer #{token}")
  end

  describe 'GET /cards' do
    it 'status 200' do
      get '/cards'

      assert_equal last_response.status, 200
    end
  end
end