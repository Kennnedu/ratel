# frozen_string_literal: true

class FindRecords
  attr_reader :params

  def initialize
    @params = RecordsParams.new
  end

  def call(scope: Record.all, params: {})
    @params.params = params
    @scope = scope
    filter
    order
    @scope
  end

  private

  def filter
    filter_by_ids
    filter_by_name
    filter_by_card
    filter_by_tag
    filter_by_ammount
    filter_by_performed_at
    uniq
  end

  def filter_by_ids
    @scope = @scope.where(id: @params.only_ids) if @params.only_ids
    @scope = @scope.where.not(id: @params.except_ids) if @params.except_ids
  end

  def filter_by_name
    @scope = @scope.only_keywords('records.name', @params.only_names) if @params.only_names
    @scope = @scope.except_keywords('records.name', @params.except_names) if @params.except_names
  end

  def filter_by_card
    @scope = @scope.left_joins(:card) if @params.join_cards?
    @scope = @scope.only_keywords('cards.name', @params.only_cards) if @params.only_cards
    return unless @params.except_cards

    @scope = @scope.except_keywords('cards.name', @params.except_cards).or(@scope.where('cards.name is null'))
  end

  def filter_by_tag
    @scope = @scope.left_joins(:tags) if @params.join_tags?
    @scope = @scope.only_keywords('tags.name', @params.only_tags) if @params.only_tags
    return unless @params.except_tags

    @scope = @scope.except_keywords('tags.name', @params.except_tags).or(@scope.where('tags.name is null'))
  end

  def filter_by_ammount
    @scope = @scope.greater_amount(@params.amount_gt) if @params.amount_gt
    @scope = @scope.less_amount(@params.amount_lt) if @params.amount_lt
  end

  def filter_by_performed_at
    @scope = @scope.greater_performed_at(@params.performed_at_gt) if @params.performed_at_gt
    @scope = @scope.less_performed_at(@params.performed_at_lt) if @params.performed_at_lt
  end

  def uniq
    @scope = @scope.distinct if @params.uniq?
  end

  def order
    @scope = @scope.order @params.order_field => @params.order_type
  end
end
