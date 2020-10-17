# frozen_string_literal: true

class FindRecordNames
  attr_reader :params

  def initialize
    @params = RecordNamesParams.new
  end

  def call(scope: Record.select(:name).group(:name), params: {})
    @params.params = params
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
    @scope = @scope.unscope(:select).select(@params.select_fields) if @params.select_fields
  end

  def filter_by_name
    @scope = @scope.where('name LIKE ?', "%#{@params.name}%") if @params.name
  end

  def filter_by_created_at
    @scope = @scope.having('min(records.created_at) > ?', @params.created_at_gt) if @params.created_at_gt
    @scope = @scope.having('min(records.created_at) < ?', @params.created_at_lt) if @params.created_at_lt
  end

  def filter_by_records_sum
    @scope = @scope.having('coalesce(sum(records.amount), 0) > ?', @params.record_sum_gt) if @params.record_sum_gt
    @scope = @scope.having('coalesce(sum(records.amount), 0) < ?', @params.record_sum_lt) if @params.record_sum_lt
  end

  def order
    @scope = @scope.order @params.order_field => @params.order_type
  end
end
