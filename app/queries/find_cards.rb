# frozen_string_literal: true

class FindCards
  attr_accessor :scope
  attr_reader :params, :record_query_object

  def initialize(scope = Card.all)
    @record_query_object = FindRecords.new
    @params = CardsParams.new
    @scope = scope
  end

  def call(user, params = {})
    @params.params = params
    select_fields
    filter_by_records_sum(user)
    order
    @scope
  end

  private

  def select_fields
    @scope = @scope.unscope(:select).select(@params.select_fields) if @params.select_fields
  end

  def filter_by_records_sum(user)
    return unless @params.join_records?

    @record_query_object.scope = user.records if user

    @scope = @scope.join_record_query(
      @record_query_object.call(@params.record_params || {}).to_sql
    )

    @scope = @scope.having('coalesce(sum(records.amount), 0) > ?', @params.record_sum_gt) if @params.record_sum_gt
    @scope = @scope.having('coalesce(sum(records.amount), 0) < ?', @params.record_sum_lt) if @params.record_sum_lt
  end

  def order
    @scope = @scope.order @params.order_field => @params.order_type
  end
end
