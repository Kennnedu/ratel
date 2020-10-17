# frozen_string_literal: true

require 'import'

module Queries
  class FindRecordNames
    include Import['queries.record_names_params']

    def call(scope: Record.select(:name).group(:name), params: {})
      record_names_params.params = params
      @scope = scope
      select_fields
      filter_by_name
      filter_by_records_sum
      filter_by_created_at
      order
      @scope
    end

    private

    def select_fields
      @scope = @scope.unscope(:select).select(record_names_params.select_fields) if record_names_params.select_fields
    end

    def filter_by_name
      @scope = @scope.where('name LIKE ?', "%#{record_names_params.name}%") if record_names_params.name
    end

    def filter_by_created_at
      if record_names_params.created_at_gt
        @scope = @scope.having('min(records.created_at) > ?', record_names_params.created_at_gt)
      end

      return unless record_names_params.created_at_lt

      @scope = @scope.having('min(records.created_at) < ?', record_names_params.created_at_lt)
    end

    def filter_by_records_sum
      if record_names_params.record_sum_gt
        @scope = @scope.having('coalesce(sum(records.amount), 0) > ?', record_names_params.record_sum_gt)
      end

      return unless record_names_params.record_sum_lt

      @scope = @scope.having('coalesce(sum(records.amount), 0) < ?', record_names_params.record_sum_lt)
    end

    def order
      @scope = @scope.order record_names_params.order_field => record_names_params.order_type
    end
  end
end
