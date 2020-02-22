require_relative '../spec_helper'

resource 'Cards' do
  let(:user) { create :user }
  let!(:cards) { create_list :card, 5, user: user }

  before do
    header 'Authorization', "Berier #{JWT.encode({user_id: user.id}, ENV.fetch('SECRET_KEY'), 'HS256')}"
  end

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  get '/cards' do
    parameter :fields, 'Specified fileds created_at, updated_at, records_sum'
    parameter :lt, 'Recrods sum less than', scope: :records_sum
    parameter :gt, 'Records sum greater than', scope: :records_sum
    parameter :type, 'Order type desc or asc', scope: :order
    parameter :field, 'Order field include all fields from card resource and records_sum if the field included in fields params',
     scope: :order
    parameter :name, 'Record name (needed to sum filtered result)', scope: :record
    parameter :card, 'Record card (needed to sum filtered result)', scope: :record
    parameter :tags, 'Record tags (needed to sum filtered result)', scope: :record
    parameter :from, 'Record perfromed from (needed to sum filtered result)', scope: :record
    parameter :to, 'Record performed to (needed to sum filtered result)', scope: :record

    let(:fields) { 'created_at,updated_at,records_sum' }
    let(:type) { 'desc' }
    let(:field) { 'name' }
  
    example_request 'index' do
      expect(status).to eq 200
    end
  end

  post '/cards' do
    let(:raw_post) { { card: { name: 'cash' } }.to_json }

    example_request 'create' do
      expect(status).to eq 200
    end
  end

  put '/cards/:id' do
    parameter :id, 'Card id'

    let(:card) { cards.last }
    let!(:id) { card.id }

    let(:raw_post) { { card: { name: 'saving' } }.to_json }

    example_request 'update' do
      expect(status).to eq 200
      expect(Card.last.name).to eq 'saving'
    end
  end

  delete '/cards/:id' do
    parameter :id, 'Card id'

    let(:card) { cards.last }
    let!(:id) { card.id }

    example_request 'delete' do
      expect(status).to eq 200
    end
  end
end