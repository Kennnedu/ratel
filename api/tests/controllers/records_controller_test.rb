require_relative './../test_helper'

describe 'Records' do
  let(:user) { User.last }

  before do
    token = authorize
    header('Authorization', "Bearer #{token}")
  end

  after(:each) do
    Record.destroy_all
  end

  describe 'GET /records' do
    let(:records_count) { 15 }
    let(:records_limit) { 5 }

    before(:all) do
      create_list :record, records_count, user: user
    end

    it 'status 200' do
      get '/records'

      assert_equal last_response.status, 200
    end

    it 'json format response' do
      get '/records'
      resp_json = JSON.parse last_response.body

      assert_equal resp_json['total_count'], records_count
      assert_equal (resp_json.keys - %w(total_count total_sum records)).empty?, true
      assert_equal (resp_json['records'].first.keys - %w(id name amount rest performed_at records_tags card)).empty?, true
    end

    it 'paginate json response' do
      get '/records', limit: records_limit, offset: records_limit
      resp_json = JSON.parse last_response.body

      assert_equal resp_json['records'].size, records_limit
      assert_equal (resp_json.keys - %w(records)).empty?, true
    end

    it 'find exact record' do
      card = create :card, name: 'cash', user: user
      date = (Date.current - 1.day).to_s

      create :record, name: 'food', amount: -3.5, card: card, user: user, performed_at: (DateTime.current - 1.day)

      get '/records', name: 'food', card: 'cash', from: date, to: date

      resp_json = JSON.parse last_response.body

      assert_equal resp_json['total_count'], 1
      assert_equal resp_json['records'].size, 1
      assert_equal resp_json['records'].first['name'], 'food'
      assert_equal (resp_json['records'].first['card'].keys - %w(id name)).empty?, true
      assert_equal resp_json['records'].first['card']['name'], 'cash'
      assert_equal resp_json['records'].first['amount'], '-3.5'
    end
  end

  describe 'GET /records/names' do
    it 'status 200' do
      get '/records/names'

      assert_equal last_response.status, 200
    end

    it 'resp json format' do
      get '/records/names'
      resp_json = JSON.parse last_response.body

      assert_equal (resp_json.keys - %w(record_names)).empty?, true
    end

    it 'find exact name' do
      create :record, name: 'shoes', user: user

      get '/records/names', keyword: 'sho'
      resp_json = JSON.parse last_response.body

      assert_equal resp_json['record_names'].include?('shoes'), true
    end
  end

  describe 'GET /dashboard' do
    it 'status 200' do
      get '/dashboard'

      assert_equal last_response.status, 200
    end
  end

  describe 'POST /records' do
    it 'status 200' do
      data = {
        "record": {
          "name": "drink",
          "amount": -4,
          "rest": 100,
          "performed_at": "2019-06-09T12:11"
        }
      }

      get '/records', data.to_json, "CONTENT_TYPE" => "application/json"

      assert_equal last_response.status, 200
    end
  end

  describe 'POST /records/bulk' do
    it 'status 200' do
      post '/records/bulk', 'html_file' => Rack::Test::UploadedFile.new('./statements_html/200420192345_statement.html', 'text/html')

      assert_equal last_response.status, 200
    end

    it 'records count' do
      post '/records/bulk', 'html_file' => Rack::Test::UploadedFile.new('./statements_html/200420192345_statement.html', 'text/html')

      assert_equal Record.count, 27
    end
  end
end