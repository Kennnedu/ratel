# frozen_string_literal: true

class FindTags
  attr_reader :params

  def initialize
    @record_query_object = FindRecords.new
    @params = TagsParams.new
  end

  def call(scope: Tag.all, record_scope: nil, params: {})
    @params.params = params
    @scope = scope
    select_fields
    filter_by_name
    filter_by_records_sum(record_scope)
    order
    @scope
  end

  private

  def select_fields
    @scope = @scope.unscope(:select).select(@params.select_fields) if @params.select_fields
  end

  def filter_by_name
    @scope = @scope.where('tags.name LIKE ?', "%#{@params.name}%") if @params.name
  end

  def filter_by_records_sum(record_scope)
    return unless @params.join_records?

    @scope = @scope.join_record_query(
      @record_query_object.call(scope: record_scope, params: @params.record_params).to_sql
    )

    @scope = @scope.having('coalesce(sum(records.amount), 0) > ?', @params.record_sum_gt) if @params.record_sum_gt
    @scope = @scope.having('coalesce(sum(records.amount), 0) < ?', @params.record_sum_lt) if @params.record_sum_lt
  end

  def order
    @scope = @scope.order @params.order_field => @params.order_type
  end
end
