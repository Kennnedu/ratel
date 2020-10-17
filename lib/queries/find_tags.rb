# frozen_string_literal: true

require 'import'

module Queries
  class FindTags
    include Import['queries.find_records', 'queries.tags_params']

    def call(scope: Tag.all, record_scope: nil, params: {})
      tags_params.params = params
      @scope = scope
      select_fields
      joins_records(record_scope)
      filter_by_name
      filter_by_records_sum
      order
      @scope
    end

    private

    def joins_records(record_scope)
      return unless tags_params.join_records?

      @scope = @scope.join_record_query(
        find_records.call(scope: record_scope, params: tags_params.record_params).to_sql
      )
    end

    def select_fields
      @scope = @scope.unscope(:select).select(tags_params.select_fields) if tags_params.select_fields
    end

    def filter_by_name
      @scope = @scope.where('tags.name LIKE ?', "%#{tags_params.name}%") if tags_params.name
    end

    def filter_by_records_sum
      @scope = @scope.having('coalesce(sum(records.amount), 0) > ?', tags_params.record_sum_gt) if tags_params.record_sum_gt
      @scope = @scope.having('coalesce(sum(records.amount), 0) < ?', tags_params.record_sum_lt) if tags_params.record_sum_lt
    end

    def order
      @scope = @scope.order tags_params.order_field => tags_params.order_type
    end
  end
end
