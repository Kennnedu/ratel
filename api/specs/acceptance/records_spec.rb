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
    parameter :name, 'Record name'
    parameter :card, 'Card name'
    parameter :tags, 'Tags name'
    parameter :from, 'Performed at from'
    parameter :to, 'Performed at to'

    example_request 'index' do
      expect(status).to eq 200
      expect(JSON.parse(response_body)['total_count']).to eq 5
    end
  end

  get '/records/names' do
    parameter :keyword, 'Records name'

    example_request 'names' do
      expect(status).to eq 200
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
    parameter :id, 'Record id'

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

  put '/records/batch' do
    parameter :name, 'Record name'
    parameter :card, 'Card name'
    parameter :tags, 'Tags name'
    parameter :from, 'Performed at from'
    parameter :to, 'Performed at to'
    parameter :name, 'Record name for updating', scope: :batch_form
    parameter :card_id, 'Card id for updating', scope: :batch_form
    parameter :removing_tag_ids, type: :array, scope: :batch_form, items: { type: :string, enum: [1,2,3]}, default: []
    parameter :records_tags_attributes, type: :array, scope: :batch_form, items: { type: :hash, enum: [ { tag_id: 1 }, { tag_id: 2 } ] }, default: []

    example_request 'update batch' do
      expect(status).to eql 200
    end
  end

  delete '/records/:id' do
    parameter :id, 'Recrods id'

    let(:record) { records.last }
    let!(:id) { record.id }

    example_request 'delete' do
      expect(status).to eql 200
    end
  end

  delete '/records/batch' do
    parameter :name, 'Record name'
    parameter :card, 'Card name'
    parameter :tags, 'Tags name'
    parameter :from, 'Performed at from'
    parameter :to, 'Performed at to'

    example_request 'delete batch' do
      expect(status).to eql 200
    end
  end
end