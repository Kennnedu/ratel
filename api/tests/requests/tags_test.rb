require_relative './../test_helper'

describe 'Tags' do
  before do
    token = authorize
    header('Authorization', "Bearer #{token}")
  end

  describe 'GET /tags' do
    it 'status 200' do
      get '/tags'

      assert_equal last_response.status, 200
    end
  end
end