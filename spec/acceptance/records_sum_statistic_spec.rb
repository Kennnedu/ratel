# frozen_string_literal: true

resource 'Records Sum Statistic' do
  let(:user) { create :user }
  let!(:records) { create_list :record, 10, user: user }

  before do
    header 'Authorization', "Berier #{JWT.encode({ user_id: user.id }, ENV.fetch('SECRET_KEY'), 'HS256')}"
  end

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  get '/records/statistic/sum' do
    parameter :type, 'Expances or Replenishment', type: :string, example: 'expenses'
    parameter :period_step, 'Round up performed at dates by interval', type: :string, enum: %w[year month week day], example: 'month', default: 'year'
    parameter :field, 'Order field', scope: :order, type: :string, enum: %w[performed_date sum_amount], example: 'amount', default: 'performed_date'
    parameter :type, 'Order type', scope: :order, type: :string, enum: %w[asc desc], example: 'asc', default: 'desc'

    let(:period_step) { 'month' }

    example_request 'Index' do
      expect(status).to eql 200
      expect(JSON.parse(response_body).keys).to include 'statistic'
    end
  end
end
