# frozen_string_literal: true

resource 'Tags' do
  let(:user) { create :user }

  before do
    Array.new(10){ Faker::App.name }.uniq.each do |name|
      create :tag, name: name, user: user
    end
  end

  before do
    header 'Authorization', "Berier #{JWT.encode({ user_id: user.id }, ENV.fetch('SECRET_KEY'), 'HS256')}"
  end

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  get '/tags' do
    parameter :name, 'Tag name', type: :string, example: 'foo'
    parameter :fields, 'Specified fileds', type: :string, enum: %w[created_at,updated_at records_sum], example: 'created_at,updated_at,records_sum'
    parameter :lt, 'Recrods sum less than', scope: :records_sum, type: :integer, example: 2000
    parameter :gt, 'Records sum greater than', scope: :records_sum, type: :integer, example: -2000
    parameter :type, 'Order type', scope: :order, type: :string, enum: %w[desc asc], example: 'asc', default: 'desc'
    parameter :field, 'Order field include all fields from card resource and records_sum if the field included in fields params',
              scope: :order, type: :string, enum: %w[name created_at updated_at records_sum], default: 'created_at', example: 'records_sum'
    parameter :name, 'Record name (needed to sum filtered result)', scope: :record, type: :string, example: 'sh&!ra'
    parameter :card, 'Record card (needed to sum filtered result)', scope: :record, type: :string, example: '33&!55'
    parameter :tags, 'Record tags (needed to sum filtered result)', scope: :record, type: :string, example: 'la&!ba'
    parameter :gt, 'Record perfromed greater than (needed to sum filtered result)', scope: %i[record performed_at],
                                                                                    type: :string, example: '2020-02-02T18:56:00.000Z'
    parameter :lt, 'Record performed less than (needed to sum filtered result)', scope: %i[record performed_at],
                                                                                 type: :string, example: '2020-02-02T18:56:00.000Z'

    let(:fields) { 'created_at,updated_at,records_sum' }
    let(:type) { 'desc' }
    let(:field) { 'name' }

    example_request 'List' do
      expect(status).to eq 200
    end
  end

  post '/tags' do
    context 'status 200' do
      let(:raw_post) { { tag: { name: 'food' } }.to_json }

      example_request 'Create' do
        expect(status).to eq 200
      end
    end

    context 'status 400' do
      let(:raw_post) { { tag: { name: '' } }.to_json }

      example_request 'Create validation error' do
        expected_resp = {
          "message" => ['Name can\'t be blank']
        }.to_json

        expect(status).to eq 400
        expect(response_body).to eq expected_resp
      end
    end
  end

  put '/tags/:id' do
    parameter :id, 'Tag id', type: :integer

    context 'status 200' do
      let!(:id) { Tag.last.id }
      let(:name) { 'iphone' }

      let(:raw_post) { { tag: { name: name } }.to_json }

      example_request 'Update' do
        expect(status).to eq 200
        expect(Tag.last.name).to eq name
      end
    end

    context 'status 400' do
      let!(:id) { Tag.last.id }

      let!(:raw_post) { { tag: { name: Tag.first.name } }.to_json }

      example_request 'Update validation error' do
        expect(status).to eq 400
        expect(response_body).to eq({ "message" => ['Name has already been taken'] }.to_json)
      end
    end

    context 'status 404' do
      let!(:id) { 666 }

      let(:raw_post) { { tag: { name: 'saving' } }.to_json }

      example_request 'Update not found' do
        expect(status).to eq 404
        expect(response_body).to eq({ 'message' => 'Not found' }.to_json)
      end
    end
  end

  delete '/tags/:id' do
    parameter :id, 'Tag id', type: :integer

    context 'status 200' do
      let!(:id) { Tag.last.id }

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
