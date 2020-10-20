# frozen_string_literal: true

module Queries
  class FindCards
    include Import['queries.find_records', 'queries.cards_params']

    def call(scope: Card.all, record_scope: nil, params: {})
      cards_params.params = params
      @scope = scope
      select_fields
      joins_records(record_scope)
      filter_by_records_sum
      order
      @scope
    end

    private

    def joins_records(record_scope)
      return unless cards_params.join_records?

      @scope = @scope.join_record_query(
        find_records.call(scope: record_scope, params: cards_params.record_params).to_sql
      )
    end

    def select_fields
      @scope = @scope.unscope(:select).select(cards_params.select_fields) if cards_params.select_fields
    end

    def filter_by_records_sum
      if cards_params.record_sum_gt
        @scope = @scope.having('coalesce(sum(records.amount), 0) > ?', cards_params.record_sum_gt)
      end

      return unless cards_params.record_sum_lt

      @scope = @scope.having('coalesce(sum(records.amount), 0) < ?', cards_params.record_sum_lt)
    end

    def order
      @scope = @scope.order cards_params.order_field => cards_params.order_type
    end
  end
end
