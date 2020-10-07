RSpec.describe FindRecords do  
  describe '.call' do
    subject(:result) { described_class.new.call(params) }

    context 'without params' do
      let(:params) { {} }

      it { expect(result.to_sql).to eq Record.order('records.performed_at': 'desc').to_sql }
    end

    context 'with correct params' do
      subject(:params) { {
        'name' => only_names.join('&') + '&' + except_names.map {|n| "!#{n}"}.join('&'),
        'card' => only_cards.join('&') + '&' + except_cards.map {|n| "!#{n}"}.join('&'),
        'tags' => only_tags.join('&') + '&' + except_tags.map {|n| "!#{n}"}.join('&'),
        'amount' =>  {
          'gt' => amount_gt,
          'lt' => amount_lt
        },
        'performed_at' => {
          'gt' => performed_gt,
          'lt' => performed_lt
         },
         'order' => {
           'field' => order_field,
           'type' => order_type
         }
      } }

      let(:only_names) { Array.new(rand(1..10)) { Faker::Food.spice } }
      let(:except_names) { Array.new(rand(1..10)) { Faker::Food.dish } }
      let(:only_cards) { Array.new(rand(1..10)) { Faker::Finance.credit_card } }
      let(:except_cards) { Array.new(rand(1..10)) { Faker::Finance.credit_card } }
      let(:only_tags) { Array.new(rand(1..10)) { Faker::App.name } }
      let(:except_tags) { Array.new(rand(1..10)) { Faker::App.name } }
      let(:amount_gt) { rand(-100.00..-1.00).round(2) }
      let(:amount_lt) { rand(1.00..100.00).round(2) }
      let(:performed_gt) { rand((Time.now - 1.year)...Time.now).to_s }
      let(:performed_lt) { rand(Time.now...(Time.now + 1.year)).to_s }
      let(:order_field) { Record.column_names.sample }
      let(:order_type) { %w[asc desc].sample }

      it 'equal sql string' do
        query = Record.only_keywords('records.name', only_names.map {|n| "%#{n}%" })
                      .except_keywords('records.name', except_names.map {|n| "%#{n}%" })
                      .left_joins(:card).only_keywords('cards.name', only_cards.map {|c| "%#{c}%" })
        query = query.except_keywords('cards.name', except_cards.map {|c| "%#{c}%" }).or(query.where('cards.name is null'))
                     .left_joins(:tags).only_keywords('tags.name', only_tags.map {|t| "%#{t}%" })
        query_sql = query.except_keywords('tags.name', except_tags.map {|t| "%#{t}%" }).or(query.where('tags.name is null'))
                         .greater_amount(amount_gt).less_amount(amount_lt)
                         .greater_performed_at(DateTime.parse(performed_gt)).less_performed_at(DateTime.parse(performed_lt) + 1.day)
                         .distinct.order(order_field => order_type).to_sql

        expect(result.to_sql).to eq query_sql
      end
    end

    context 'with wrong params' do
      subject(:params) { {
        'tags' => only_tags,
        'amount' =>  {
          'gt' => amount_gt
        },
        'performed_at' => {
          'gt' => 'performed_gt',
          'lt' => 'performed_lt'
         },
         'order' => {
          'field' => 'order_field',
          'type' => 'order_type'
        }
      } }

      let(:only_tags) { 323847 }
      let(:amount_gt) { 'amount_gt' }

      it 'equal sql string' do 
        query_sql = Record.left_joins(:tags).only_keywords('tags.name', ["%#{only_tags.to_s}%"]).greater_amount(0.0)
                          .distinct.order('records.performed_at': 'desc').to_sql

        expect(result.to_sql).to eq  query_sql
      end
    end
  end
end
