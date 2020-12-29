RSpec.describe 'FindRecordsSum' do
  describe '.call' do
    subject(:result) { Container['queries.find_records_sum'].call(params: params) }

    context 'without params' do
      let(:params) { {} } 

      it 'equal sql string' do
        query = Record.select('date_trunc(\'year\', performed_at) as performed_date, sum(amount) as sum_amount')
                      .from(Record.all).group('performed_date').order('performed_date desc')

        expect(result.to_sql).to eq query.to_sql
      end 
    end

    context 'with correct params' do
      let(:params) { { 
        'type' => %w[expences replenish].sample,
        'period_step' => %w[year month week day].sample,
        'order' => {
          'field' => %w[performed_date sum_amount].sample,
          'type' => %w[asc desc].sample
        }
      } }

      it 'equal sql string' do
        subquery = if params['type'].eql? 'expences'
                     Record.all.where('records.amount < 0')
                   else
                     Record.all.where('records.amount > 0')
                   end

        query = Record.select("date_trunc('#{params['period_step']}', performed_at) as performed_date, sum(amount) as sum_amount")
                      .from(subquery).group('performed_date').order("#{params['order']['field']} #{params['order']['type']}")

        expect(result.to_sql).to eq query.to_sql
      end
    end

    context 'with wrong params' do
      let(:params) { {
        'type' => 'EXPANCES',
        'period_step' => 'a week',
        'order' => {
          'field' => 'performed_at',
          'type' => 'DASC' 
        } 
      } }

      it 'equal sql string' do
        query = Record.select('date_trunc(\'year\', performed_at) as performed_date, sum(amount) as sum_amount')
                      .from(Record.all).group('performed_date').order('performed_date desc')

        expect(result.to_sql).to eq query.to_sql
      end
    end
  end
end
