# frozen_string_literal: true

resource 'Records' do
  let(:user) { create :user }
  let!(:records) { create_list :record, 5, user: user }

  before do
    header 'Authorization', "Berier #{JWT.encode({ user_id: user.id }, ENV.fetch('SECRET_KEY'), 'HS256')}"
  end

  header 'Accept', 'application/json'

  get '/records' do
    parameter :name, 'Record name (enumiration through & and ! to exclude)', type: :string, example: 'ex&!blo'
    parameter :card, 'Card name (enumiration through & and ! to exclude)', type: :string, example: '33&!66'
    parameter :tags, 'Tags name (enumiration through & and ! to exclude)', type: :string, example: 'blo&!mor'
    parameter :gt, 'Performed at greater than', scope: :performed_at, type: :string, example: '2020-02-02T18:56:00.000Z'
    parameter :lt, 'Performed at less than', scope: :performed_at, type: :string, example: '2020-02-02T18:56:00.000Z'
    parameter :field, 'Order field', scope: :order, type: :string, enum: Record.column_names, example: 'amount', default: 'performed_at'
    parameter :type, 'Order type', scope: :order, type: :string, enum: %w[asc desc], example: 'asc', default: 'desc'
    parameter :limit, 'Limit number of records', type: :integer, example: 10, default: 30
    parameter :offset, 'Offset number of records', type: :integer, example: 5, default: 0

    example_request 'List' do
      expect(status).to eq 200
      expect(JSON.parse(response_body)['total_count']).to eq 5
    end
  end

  post '/records' do
    let(:tag) { create :tag, name: 'food', user: user }
    let(:card) { create :card, user: user }

    context 'status 200' do
      let(:raw_post) do
        {
          record: {
            name: 'macdonalds',
            amount: -3.55,
            rest: 11.23,
            performed_at: DateTime.current.strftime('%FT%R'),
            card_id: card.id,
            records_tags_attributes: [{ tag_id: tag.id }]
          }
        }.to_json
      end
  
      example_request 'Create' do
        expect(status).to eql 200
      end
    end

    context 'status 400' do
      let(:raw_post) do
        {
          record: {
            rest: 11.23,
            performed_at: DateTime.current.strftime('%FT%R'),
            card_id: card.id,
            records_tags_attributes: [{ tag_id: tag.id }]
          }
        }.to_json
      end
  
      example_request 'Create validation error' do
        expect(status).to eql 400
        expect(response_body).to eq({'message' => ['Name can\'t be blank', 'Amount can\'t be blank']}.to_json)
      end
    end
  end

  put '/records/:id' do
    parameter :id, 'Record id', type: :integer

    context 'status 200' do
      let!(:id) { records.last.id }
      let(:card) { create :card, user: user }
  
      let(:raw_post) do
        {
          record: {
            name: 'Starbacks',
            amount: -4.12,
            card_id: card.id
          }
        }.to_json
      end
  
      example_request 'Update' do
        expect(status).to eql 200
      end
    end

    context 'status 400' do
      let!(:id) { records.last.id }
      let(:card) { create :card, user: user }

      let(:raw_post) do
        {
          record: {
            name: '',
            amount: nil,
            card_id: card.id
          }
        }.to_json
      end
  
      example_request 'Update validation error' do
        expect(status).to eql 400
        expect(response_body).to eq({'message' => ['Name can\'t be blank', 'Amount can\'t be blank']}.to_json)
      end
    end

    context 'status 404' do
      let!(:id) { 666 }

      let(:raw_post) do
        {
          record: { name: '11' }
        }.to_json
      end
  
      example_request 'Update not found' do
        expect(status).to eql 404
        expect(response_body).to eq({ 'message' => 'Not found' }.to_json)
      end
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
    parameter :removing_tag_ids, type: :array, scope: :batch_form, items: { type: :integer }, example: [1, 2, 3], default: []
    parameter :records_tags_attributes, type: :array, scope: :batch_form, items: { type: :hash },
      example: [{ tag_id: 1 }, { tag_id: 2 }], default: []

    context 'status 200' do
      let(:batch_form_name) { 'shopping' }

      example_request 'Update batch' do
        expect(status).to eql 200
        expect(Record.pluck(:name).uniq.size).to eql(1)
      end
    end
    
    context 'status 400' do
      let(:batch_form_name) { '' }

      example_request 'Update batch validation error' do
        expect(status).to eql 400
      end
    end
  end

  delete '/records/:id' do
    parameter :id, 'Recrods id', type: :integer

    context 'status 200' do
      let!(:id) { records.last.id }
  
      example_request 'Delete' do
        expect(status).to eql 200
      end
    end

    context 'status 404' do
      let!(:id) { 666 }

      example_request 'Delete not found' do
        expect(status).to eql 404
      end
    end
  end

  delete '/records' do
    parameter :name, 'Record name (enumiration through & and ! to exclude)', type: :string, example: 'ex&!blo'
    parameter :card, 'Card name (enumiration through & and ! to exclude)', type: :string, example: '33&!66'
    parameter :tags, 'Tags name (enumiration through & and ! to exclude)', type: :string, example: 'blo&!mor'
    parameter :gt, 'Performed at greater than', scope: :performed_at, type: :string, example: '2020-02-02T18:56:00.000Z'
    parameter :lt, 'Performed at less than', scope: :performed_at, type: :string, example: '2020-02-02T18:56:00.000Z'

    example_request 'Delete batch' do
      expect(status).to eql 200
    end
  end
end
