require_relative '../spec_helper'
require 'jwt'

resource 'Records' do
  let(:user) { create :user }
  let!(:records) { create_list :record, 5, user: user }

  before do
    header 'Authorization', "Berier #{JWT.encode({user_id: user.id}, ENV.fetch('SECRET_KEY'), 'HS256')}"
  end

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  get '/records' do
    example_request 'index' do
      expect(status).to eq 200
    end
  end

  get '/records/names' do
    example_request 'names' do
      expect(status).to eq 200
    end
  end

  post '/records' do
  end

  put '/records/:id' do
  end

  put '/records/batch' do
  end

  delete '/records/:id' do
  end

  delete '/records/batch' do
  end
end