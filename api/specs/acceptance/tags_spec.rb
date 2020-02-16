require_relative '../spec_helper'

resource 'Tags' do
  let(:user) { create :user }
  let!(:tags) { create_list :tag, 5, user: user }

  before do
    header 'Authorization', "Berier #{JWT.encode({user_id: user.id}, ENV.fetch('SECRET_KEY'), 'HS256')}"
  end

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  get '/tags' do
    parameter :keyword, 'Tag name'

    example_request 'index' do
      expect(status).to eq 200
    end
  end

  post '/tags/:name' do
    parameter :name, 'Tag name'

    let(:name) { 'shop' }

    example_request 'find or create' do
      expect(status).to eq 200
    end
  end
end