RSpec.describe 'FindRecordsSum' do
  describe '.call' do
    subject(:result) { Container['queries.find_records_sum'].call(params: params) }

    context 'without params' do
      let(:params) { {} } 

      it 'equal sql string' do
        query = Record.select('date_trunc(\'year\', performed_at) as performed_date, sum(amount) as sum_amount')
                      .from(Record.select('id, amount, performed_at')).group('performed_date').order('performed_date desc')

        expect(result.to_sql).to eq query.to_sql
      end 
    end

    subject(:params) { {
      'type' => type,
      'period_step' => period_step,
      'order' => {
        'field' => order_field,
        'type' => order_type
      },
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
      }
    } }

    context 'with correct params' do
      let(:type) { %w[expences replenish].sample }
      let(:period_step) { %w[year month week day].sample }
      let(:order_field) { %w[performed_date sum_amount].sample }
      let(:order_type) { %w[asc desc].sample }
      let(:record_name) { 'ticket&!food&milk&!iphone' }
      let(:record_card) { '33&!666&777' }
      let(:record_tags) { 'credit&!food&mac' }
      let(:record_amount_gt) { rand(-100.00..-1.00).round(2) }
      let(:record_amount_lt) { rand(1.00..100.00).round(2) }
      let(:record_performed_gt) { rand((Time.now - 1.year)...Time.now).to_s }
      let(:record_performed_lt) { rand(Time.now...(Time.now + 1.year)).to_s }
      let(:records_sum_gt) { rand(-100.00..-1.00).round(2) }
      let(:records_sum_lt) { rand(1.00..100.00).round(2) }

      it 'equal sql string' do
        records_query = Record.all
         .only_keywords('records.name', record_name.split('&').reject{ |n| n[0].eql?('!') }.map {|n| "%#{n}%" })
         .except_keywords('records.name', record_name.split('&').select{ |n| n[0].eql?('!') }.map {|n| "%#{n[1..-1]}%" })
         .left_joins(:card)
         .only_keywords('cards.name', record_card.split('&').reject{ |n| n[0].eql?('!') }.map {|n| "%#{n}%" })

        records_query = records_query
         .except_keywords('cards.name', record_card.split('&').select{ |n| n[0].eql?('!') }.map {|n| "%#{n[1..-1]}%" })
         .or(records_query.where('cards.name is null'))
         .left_joins(:tags)
         .only_keywords('tags.name', record_tags.split('&').reject{ |n| n[0].eql?('!') }.map {|n| "%#{n}%" })

        records_query = records_query
         .except_keywords('tags.name', record_tags.split('&').select{ |n| n[0].eql?('!') }.map {|n| "%#{n[1..-1]}%" })
         .or(records_query.where('tags.name is null'))
         .greater_amount(record_amount_gt).less_amount(record_amount_lt)
         .greater_performed_at(DateTime.parse(record_performed_gt))
         .less_performed_at(DateTime.parse(record_performed_lt) + 1.day)
         .distinct.order('records.performed_at': 'desc')

        subquery = Record.select('id, amount, performed_at').from records_query

        subquery = subquery.where("amount #{params['type'].eql?('expences') ? '<' : '>'} 0")

        query = Record.select("date_trunc('#{params['period_step']}', performed_at) as performed_date, sum(amount) as sum_amount")
                      .from(subquery).group('performed_date').order("#{params['order']['field']} #{params['order']['type']}")

        expect(result.to_sql).to eq query.to_sql
      end
    end

    context 'with wrong params' do
      let(:type) { 'EXPENCES' }
      let(:period_step) { 'this month please' }
      let(:order_field) { 'id' }
      let(:order_type) { 'from A to Z' }
      let(:record_name) { nil }
      let(:record_card) { nil }
      let(:record_tags) { nil }
      let(:record_amount_gt) { 'three' }
      let(:record_amount_lt) { 'seven' }
      let(:record_performed_gt) { 'yesterday' }
      let(:record_performed_lt) { 'today' }
      let(:records_sum_gt) { 'siz' }
      let(:records_sum_lt) { 'five' }

      it 'equal sql string' do
        records_query = Record.all
          .greater_amount(record_amount_gt.to_f).less_amount(record_amount_lt.to_f)
          .order('records.performed_at': 'desc')

        subquery = Record.select('id, amount, performed_at').from records_query

        query = Record.select('date_trunc(\'year\', performed_at) as performed_date, sum(amount) as sum_amount')
                      .from(subquery).group('performed_date').order('performed_date desc')

        expect(result.to_sql).to eq query.to_sql
      end
    end
  end
end
