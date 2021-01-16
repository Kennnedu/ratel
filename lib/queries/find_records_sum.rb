# frozen_string_literal: true

module Queries
  class FindRecordsSum
    include Import['queries.find_records']

    def call(scope: Record.select('id, amount, performed_at'), params: {})
      @scope = scope

      filter_by_records_filter params['record']
      filter_by_type params['type']
      filter_by_period_step params['period_step']
      order params['order']

      @scope
    end

    private

    def filter_by_records_filter(record_params)
      return unless record_params.presence

      @scope = @scope.from find_records.call(params: record_params)
    end

    def filter_by_type(type)
      if type.eql? 'expences'
        @scope = @scope.where('amount < 0')
      elsif type.eql? 'replenish'
        @scope = @scope.where('amount > 0')
      end
    end

    def filter_by_period_step(period_step)
      period_step = %w[year quarter month week day].include?(period_step) ? period_step : 'year'

      @scope = Record.select("date_trunc('#{period_step}', performed_at) as performed_date, sum(amount) as sum_amount")
                     .from(@scope).group('performed_date')
    end

    def order(params)
      order_field = %w[performed_date sum_amount].include?(params&.dig('field')) ? params&.dig('field') : 'performed_date'
      order_type = %w[asc desc].include?(params&.dig('type')) ? params&.dig('type') : 'desc'

      @scope = @scope.order("#{order_field} #{order_type}")
    end
  end
end
