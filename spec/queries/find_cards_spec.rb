RSpec.describe FindCards do
  before { create :user }

  let(:user) { User.last }

  describe '.call' do
    subject(:result) { described_class.new.call(record_scope: user.records, params: params) }

    context 'without params' do
      let(:params) { {} }

      it { expect(result.to_sql).to eq Card.order('cards.created_at': 'desc').to_sql }
    end

    subject(:params) { {
      'fields' => fields,
      'record' => {
        'name' => record_name,
        'card' => record_card,
        'tags' => record_tags,
        'amount' => {
          'gt' => record_amount_gt,
          'lt' => record_amount_lt
        },
        'performed_at' => {
          'gt' => record_performed_gt,
          'lt' => record_performed_lt
         }
      },
      'records_sum' => {
        'gte' => records_sum_gt,
        'lte' => records_sum_lt
      },
      'order' => {
        'field' => order_field,
        'type' => order_type
      }
    } }

    context 'with correct params' do
      let(:fields) { 'created_at,updated_at,records_sum' }
      let(:record_name) { 'ticket&!food&milk&!iphone' }
      let(:record_card) { '33&!666&777' }
      let(:record_tags) { 'credit&!food&mac' }
      let(:record_amount_gt) { rand(-100.00..-1.00).round(2) }
      let(:record_amount_lt) { rand(1.00..100.00).round(2) }
      let(:record_performed_gt) { rand((Time.now - 1.year)...Time.now).to_s }
      let(:record_performed_lt) { rand(Time.now...(Time.now + 1.year)).to_s }
      let(:records_sum_gt) { rand(-100.00..-1.00).round(2) }
      let(:records_sum_lt) { rand(1.00..100.00).round(2) }
      let(:order_field) { %w[name created_at updated_at records_sum].sample }
      let(:order_type) { %w[asc desc].sample }

      it 'equal sql string' do
        record_query = Record.all
          .where(user: user)
          .only_keywords('records.name', record_name.split('&').reject{ |n| n[0].eql?('!') }.map {|n| "%#{n}%" })
          .except_keywords('records.name', record_name.split('&').select{ |n| n[0].eql?('!') }.map {|n| "%#{n[1..-1]}%" })
          .left_joins(:card)
          .only_keywords('cards.name', record_card.split('&').reject{ |n| n[0].eql?('!') }.map {|n| "%#{n}%" })
        
        record_query = record_query
          .except_keywords('cards.name', record_card.split('&').select{ |n| n[0].eql?('!') }.map {|n| "%#{n[1..-1]}%" })
          .or(record_query.where('cards.name is null'))
          .left_joins(:tags)
          .only_keywords('tags.name', record_tags.split('&').reject{ |n| n[0].eql?('!') }.map {|n| "%#{n}%" })
        
        records_sql = record_query
          .except_keywords('tags.name', record_tags.split('&').select{ |n| n[0].eql?('!') }.map {|n| "%#{n[1..-1]}%" })
          .or(record_query.where('tags.name is null'))
          .greater_amount(record_amount_gt).less_amount(record_amount_lt)
          .greater_performed_at(DateTime.parse(record_performed_gt))
          .less_performed_at(DateTime.parse(record_performed_lt) + 1.day)
          .distinct.order('records.performed_at': 'desc').to_sql

        query_order_field = order_field.eql?('records_sum') ? 'records_sum' : "cards.#{order_field}"
        
        query_sql = Card.all
          .select("cards.id, cards.name, cards.created_at, cards.updated_at, coalesce(sum(records.amount), 0) as records_sum")
          .join_record_query(records_sql)
          .having('coalesce(sum(records.amount), 0) > ?', records_sum_gt)
          .having('coalesce(sum(records.amount), 0) < ?', records_sum_lt)
          .order(query_order_field => order_type).to_sql

        expect(result.to_sql).to eq query_sql
      end
    end

    context 'with wrong params' do
      let(:fields) { 'created_name_at,updated_at,records_sum' }
      let(:record_name) { nil }
      let(:record_card) { nil }
      let(:record_tags) { nil }
      let(:record_amount_gt) { 'three' }
      let(:record_amount_lt) { 'seven' }
      let(:record_performed_gt) { 'yesterday' }
      let(:record_performed_lt) { 'today' }
      let(:records_sum_gt) { 'siz' }
      let(:records_sum_lt) { 'five' }
      let(:order_field) { %w[createda_card_at udpdated_card_at card_records_sum].sample }
      let(:order_type) { %w[assc desci].sample }

      it 'equal sql string' do
        records_sql = Record.all
          .where(user: user)
          .greater_amount(record_amount_gt.to_f).less_amount(record_amount_lt.to_f)
          .order('records.performed_at': 'desc').to_sql

           
        query_sql = Card.all
          .select("cards.id, cards.name, cards.updated_at, coalesce(sum(records.amount), 0) as records_sum")
          .join_record_query(records_sql)
          .having('coalesce(sum(records.amount), 0) > ?', records_sum_gt.to_f)
          .having('coalesce(sum(records.amount), 0) < ?', records_sum_lt.to_f)
          .order('cards.created_at': 'desc').to_sql

        expect(result.to_sql).to eq query_sql
      end
    end
  end
end
