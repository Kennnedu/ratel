RSpec.describe 'FindRecordNames' do
  describe '.call' do
    subject(:result) { Container['queries.find_record_names'].call(params: params) }

    context 'without params' do
      let(:params) { {} }

      it { expect(result.to_sql).to eq Record.select(:name).group(:name).order('records.name':  'ASC').to_sql }
    end
    
    subject(:params) { { 
      'fields' => fields, 
      'name' => name,
      'records_sum' => {
        'gte' => records_sum_gt,
        'lte' => records_sum_lt
      },
      'created_name_at' => {
        'gt' => created_name_at_gt,
        'lt' => created_name_at_lt
      },
      'order' => {
        'field' => order_field,
        'type' => order_type
      }
    } }

    
    context 'with correct params' do
      let(:fields) {'created_name_at,records_sum'} 
      let(:name) { Faker::Food.fruits }
      let(:records_sum_gt) { rand(-100.00..-1.00).round(2) }
      let(:records_sum_lt) { rand(1.00..100.00).round(2) }
      let(:created_name_at_gt) { rand((Time.now - 1.year)...Time.now).to_s }
      let(:created_name_at_lt) { rand(Time.now...(Time.now + 1.year)).to_s }
      let(:order_field) { %w[name created_name_at records_sum].sample }
      let(:order_type) { %w[asc desc].sample }

      it 'equal sql string' do
        query_order_field = order_field.eql?('name') ? 'records.name' : order_field

        query_sql = Record.select(:name).group(:name).unscope(:select)
                          .select('records.name, min(records.created_at) as created_name_at, sum(records.amount) as records_sum')
                          .where('name LIKE ?', "%#{name}%").having('coalesce(sum(records.amount), 0) > ?', records_sum_gt)
                          .having('coalesce(sum(records.amount), 0) < ?', records_sum_lt)
                          .having('min(records.created_at) > ?', DateTime.parse(created_name_at_gt))
                          .having('min(records.created_at) < ?', DateTime.parse(created_name_at_lt))
                          .order(query_order_field => order_type).to_sql
        expect(result.to_sql).to eq query_sql
      end

    end

    context 'with wrong params' do
      let(:name) { 33 } 
      let(:fields) { 33 } 
      let(:records_sum_gt) { 'five' }
      let(:records_sum_lt) { 'ten' }
      let(:created_name_at_gt) { 'today' }
      let(:created_name_at_lt) { 'tomorrow' }
      let(:order_field) { %w[word created_time_name_at tags_sum records_susm].sample }
      let(:order_type) { %w[ascz dAesc].sample }

      it 'equal sql string' do
        query_sql = Record.select(:name).group(:name)
          .where('name LIKE ?', "%#{name}%")
          .having('coalesce(sum(records.amount), 0) > ?', records_sum_gt.to_f)
          .having('coalesce(sum(records.amount), 0) < ?', records_sum_lt.to_f)
          .order('records.name': 'ASC').to_sql

        expect(result.to_sql).to eq query_sql
      end 
    end
  end
end
