require_relative '../spec_helper'

resource 'Tags' do
  let(:user) { create :user }

  before do
    create_list :tag, 10, user: user
  end

  before do
    header 'Authorization', "Berier #{JWT.encode({user_id: user.id}, ENV.fetch('SECRET_KEY'), 'HS256')}"
  end

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  get '/tags' do
    parameter :name, 'Tag name', type: :string, example: 'foo'
    parameter :fields, 'Specified fileds', type: :string, enum: %w(created_at,updated_at records_sum), example: 'created_at,updated_at,records_sum'
    parameter :lt, 'Recrods sum less than', scope: :records_sum, type: :integer, example: 2000
    parameter :gt, 'Records sum greater than', scope: :records_sum, type: :integer, example: -2000
    parameter :type, 'Order type', scope: :order, type: :string, enum: %w(desc asc), example: 'asc', default: 'desc'
    parameter :field, 'Order field include all fields from card resource and records_sum if the field included in fields params',
      scope: :order, type: :string, enum: %w(name created_at updated_at records_sum), default: 'created_at', example: 'records_sum'
    parameter :name, 'Record name (needed to sum filtered result)', scope: :record, type: :string, example: 'sh&!ra'
    parameter :card, 'Record card (needed to sum filtered result)', scope: :record, type: :string, example: '33&!55'
    parameter :tags, 'Record tags (needed to sum filtered result)', scope: :record, type: :string, example: 'la&!ba'
    parameter :from, 'Record perfromed from (needed to sum filtered result)', scope: :record, type: :string, example: '2020-02-02T18:56:00.000Z'
    parameter :to, 'Record performed to (needed to sum filtered result)', scope: :record, type: :string, example: '2020-02-02T18:56:00.000Z'

    let(:fields) { 'created_at,updated_at,records_sum' }
    let(:type) { 'desc' }
    let(:field) { 'name' }

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