require_relative '../spec_helper'

resource 'Records Names' do
  let(:user) { create :user }
  let!(:records) { create_list :record, 10, user: user }

  before do
    header 'Authorization', "Berier #{JWT.encode({user_id: user.id}, ENV.fetch('SECRET_KEY'), 'HS256')}"
  end

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  get '/records/names' do
    parameter :name, 'Records name', type: :string, example: 'bo'
    parameter :fields, 'Specified fileds', type: :string, enum: %w(created_at records_sum), example: 'created_at,records_sum'
    parameter :lt, 'Amount records names less than', scope: [:record, :amount], type: :integer, example: 100
    parameter :gt, 'Amount records names greater than', scope: [:record, :amount], type: :integer, example: -100
    parameter :lt, 'Recrods sum less than', scope: :records_sum, type: :integer, example: 2000
    parameter :gt, 'Records sum greater than', scope: :records_sum, type: :integer, example: -2000
    parameter :lt, 'Records name created at less than', scope: :created_name_at, type: :string, example: '2020-02-02T18:56:00.000Z'
    parameter :gt, 'Records name created at greater than', scope: :created_name_at, type: :string, example: '2020-02-02T18:56:00.000Z'
    parameter :type, 'Order type', scope: :order, type: :string, enum: %w(desc asc), example: 'desc', default: 'asc'
    parameter :field, 'Order field include all fields from card resource and records_sum if the field included in fields params',
      scope: :order, type: :string, enum: %w(name created_at records_sum), default: 'name', example: 'records_sum'
    
    let(:fields) { 'created_at,updated_at,records_sum' }
    let(:type) { 'desc' }
    let(:field) { 'name' }

    example_request 'index' do
      expect(status).to eq 200
    end
  end
end