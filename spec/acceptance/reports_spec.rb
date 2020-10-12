# frozen_string_literal: true

resource 'Reports' do
  let(:user) { create :user }

  before do
    header 'Authorization', "Berier #{JWT.encode({ user_id: user.id }, ENV.fetch('SECRET_KEY'), 'HS256')}"
  end

  header 'Accept', 'application/json'

  get '/reports' do
    example_request 'List' do
      expect(status).to eq 200
    end
  end

  post '/reports' do
    header 'Content-Type', 'multipart/form-data'

    parameter :document, type: :file, required: true

    context 'status 200' do
      let(:document) { Rack::Test::UploadedFile.new("#{Dir.pwd}/spec/fixtures/report.htm", "text/html") }
  
      example_request 'Create' do
        expect(status).to eq 200
      end
    end
  end

  delete '/reports/:id' do
    parameter :id, 'Report id', type: :integer
    let(:report) { create :report, user: user }

    context 'status 200' do
      let!(:id) { report.id }

      example_request 'Delete' do
        expect(status).to eq 200
      end
    end

    context 'status 404' do
      let!(:id) { 666 }

      example_request 'Delete Not found' do
        expect(status).to eq 404
        expect(response_body).to eq({ 'message' => 'Not found' }.to_json)
      end
    end
  end
end
