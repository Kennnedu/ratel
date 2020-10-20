# frozen_string_literal: true

module Queries
  class RecordsParams
    KEYWORD_SEPARATOR = '&'
    KEYWORD_EXCLUDE = '!'

    attr_reader :params

    def params=(params)
      @params = params || {}
      @only_names = nil
      @except_names = nil
      @only_cards = nil
      @except_cards = nil
      @only_tags = nil
      @except_tags = nil
      @performed_at_gt = nil
      @performed_at_lt = nil
    end

    def only_ids
      params['ids'].presence
    end

    def except_ids
      params['except_ids'].presence
    end

    def only_names
      @only_names ||= only_list(params['name'])
    end

    def except_names
      @except_names ||= except_list(params['name'])
    end

    def only_cards
      @only_cards ||= only_list(params['card'])
    end

    def except_cards
      @except_cards ||= except_list(params['card'])
    end

    def only_tags
      @only_tags ||= only_list(params['tags'])
    end

    def except_tags
      @except_tags ||= except_list(params['tags'])
    end

    def amount_gt
      params.dig('amount', 'gt')&.to_f
    end

    def amount_lt
      params.dig('amount', 'lt')&.to_f
    end

    def performed_at_gt
      @performed_at_gt ||= parse_date(params.dig('performed_at', 'gt'))
    end

    def performed_at_lt
      @performed_at_lt ||= parse_date(params.dig('performed_at', 'lt'))&.+ 1.day
    end

    def join_tags?
      (only_tags || except_tags).present?
    end

    def join_cards?
      (only_cards || except_cards).present?
    end

    def uniq?
      join_cards? || join_tags?
    end

    def order_type
      type = params.dig('order', 'type')

      %w[asc desc].include?(type) ? type : 'desc'
    end

    def order_field
      field = params.dig('order', 'field')

      Record.column_names.include?(field) ? "records.#{field}" : 'records.performed_at'
    end

    private

    def only_list(list_str)
      process_keywords_string(list_str, ->(k) { k[0] != KEYWORD_EXCLUDE }, ->(k) { "%#{k}%" })
    end

    def except_list(list_str)
      process_keywords_string(list_str, ->(k) { k[0] == KEYWORD_EXCLUDE }, ->(k) { "%#{k.gsub(KEYWORD_EXCLUDE, '')}%" })
    end

    def process_keywords_string(list_str, select_condition, keyword_process)
      list = list_str.to_s.split(KEYWORD_SEPARATOR)
      list.select! { |k| select_condition.call(k) }

      return unless list.presence

      list.map! { |k| k.presence ? keyword_process.call(k) : next }.compact!
      list
    end

    def parse_date(date_string)
      DateTime.parse(date_string)
    rescue StandardError
      nil
    end
  end
end
