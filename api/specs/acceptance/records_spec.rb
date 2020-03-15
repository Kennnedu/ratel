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
    parameter :name, 'Record name (enumiration through & and ! to exclude)', type: :string, example: 'ex&!blo'
    parameter :card, 'Card name (enumiration through & and ! to exclude)', type: :string, example: '33&!66'
    parameter :tags, 'Tags name (enumiration through & and ! to exclude)', type: :string, example: 'blo&!mor'
    parameter :gt, 'Performed at greater than', scope: :performed_at, type: :string, example: '2020-02-02T18:56:00.000Z'
    parameter :lt, 'Performed at less than', scope: :performed_at, type: :string, example: '2020-02-02T18:56:00.000Z'
    parameter :field, 'Order field', scope: :order, type: :string, enum: Record.column_names, example: 'amount', default: 'performed_at'
    parameter :type, 'Order type', scope: :order, type: :string, enum: %w(asc desc), example: 'asc', default: 'desc'
    parameter :limit, 'Limit number of records', type: :integer, example: 10, default: 30
    parameter :offset, 'Offset number of records', type: :integer, example: 5, default: 0

    example_request 'index' do
      expect(status).to eq 200
      expect(JSON.parse(response_body)['total_count']).to eq 5
    end
  end

  post '/records' do
    let(:tag) { create :tag, name: 'food', user: user }
    let(:card) { create :card, user: user }

    let(:raw_post) { 
      {
        record: {
          name: 'macdonalds',
          amount: -3.55,
          rest: 11.23,
          performed_at: DateTime.current.strftime("%FT%R"),
          card_id: card.id,
          records_tags_attributes: [ { tag_id: tag.id } ]
        }
      }.to_json
     }

    example_request 'create' do
      expect(status).to eql 200
    end
  end

  put '/records/:id' do
    parameter :id, 'Record id', type: :integer

    let(:record) { records.last }
    let!(:id) { record.id }
    let(:card) { create :card, user: user }

    let(:raw_post) { 
      {
        record: {
          name: 'Starbacks',
          amount: -4.12,
          card_id: card.id
        }
      }.to_json
    }

    example_request 'update' do
      expect(status).to eql 200
    end
  end

  put '/records' do
    parameter :name, 'Record name (enumiration through & and ! to exclude)', type: :string, example: 'ex&!blo'
    parameter :card, 'Card name (enumiration through & and ! to exclude)', type: :string, example: '33&!66'
    parameter :tags, 'Tags name (enumiration through & and ! to exclude)', type: :string, example: 'blo&!mor'
    parameter :gt, 'Performed at greater than', scope: :performed_at, type: :string, example: '2020-02-02T18:56:00.000Z'
    parameter :lt, 'Performed at less than', scope: :performed_at, type: :string, example: '2020-02-02T18:56:00.000Z'
    parameter :name, 'Record name for updating', scope: :batch_form, type: :string, example: 'food'
    parameter :card_id, 'Card id for updating', scope: :batch_form, type: :integer, example: 1 
    parameter :removing_tag_ids, type: :array, scope: :batch_form, items: { type: :integer }, example: [1,2,3], default: []
    parameter :records_tags_attributes, type: :array, scope: :batch_form, items: { type: :hash },
      example: [{ tag_id: 1 }, {tag_id: 2}], default: []

    example_request 'update batch' do
      expect(status).to eql 200
    end
  end

  delete '/records/:id' do
    parameter :id, 'Recrods id', type: :integer

    let(:record) { records.last }
    let!(:id) { record.id }

    example_request 'delete' do
      expect(status).to eql 200
    end
  end

  delete '/records' do
    parameter :name, 'Record name (enumiration through & and ! to exclude)', type: :string, example: 'ex&!blo'
    parameter :card, 'Card name (enumiration through & and ! to exclude)', type: :string, example: '33&!66'
    parameter :tags, 'Tags name (enumiration through & and ! to exclude)', type: :string, example: 'blo&!mor'
    parameter :gt, 'Performed at greater than', scope: :performed_at, type: :string, example: '2020-02-02T18:56:00.000Z'
    parameter :lt, 'Performed at less than', scope: :performed_at, type: :string, example: '2020-02-02T18:56:00.000Z'

    example_request 'delete batch' do
      expect(status).to eql 200
    end
  end
end