# frozen_string_literal: true

module Queries
  class FindRecords
    include Import['queries.records_params']

    def call(scope: Record.all, params: {})
      records_params.params = params
      @scope = scope
      joins
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

    def joins
      @scope = @scope.left_joins(:card) if records_params.join_cards?
      @scope = @scope.left_joins(:tags) if records_params.join_tags?
    end

    def filter_by_ids
      @scope = @scope.where(id: records_params.only_ids) if records_params.only_ids
      @scope = @scope.where.not(id: records_params.except_ids) if records_params.except_ids
    end

    def filter_by_name
      @scope = @scope.only_keywords('records.name', records_params.only_names) if records_params.only_names
      @scope = @scope.except_keywords('records.name', records_params.except_names) if records_params.except_names
    end

    def filter_by_card
      @scope = @scope.only_keywords('cards.name', records_params.only_cards) if records_params.only_cards
      return unless records_params.except_cards

      @scope = @scope.except_keywords('cards.name', records_params.except_cards).or(@scope.where('cards.name is null'))
    end

    def filter_by_tag
      @scope = @scope.only_keywords('tags.name', records_params.only_tags) if records_params.only_tags
      return unless records_params.except_tags

      @scope = @scope.except_keywords('tags.name', records_params.except_tags).or(@scope.where('tags.name is null'))
    end

    def filter_by_ammount
      @scope = @scope.greater_amount(records_params.amount_gt) if records_params.amount_gt
      @scope = @scope.less_amount(records_params.amount_lt) if records_params.amount_lt
    end

    def filter_by_performed_at
      @scope = @scope.greater_performed_at(records_params.performed_at_gt) if records_params.performed_at_gt
      @scope = @scope.less_performed_at(records_params.performed_at_lt) if records_params.performed_at_lt
    end

    def uniq
      @scope = @scope.distinct if records_params.uniq?
    end

    def order
      @scope = @scope.order records_params.order_field => records_params.order_type
    end
  end
end
