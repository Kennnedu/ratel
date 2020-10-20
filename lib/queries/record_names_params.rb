# frozen_string_literal: true

module Queries
  class RecordNamesParams
    SELECT_SUBSTR = 'records.name, '
    FEILDS_MAP = {
      'created_name_at' => 'min(records.created_at) as created_name_at',
      'records_sum' => 'sum(records.amount) as records_sum'
    }.freeze

    attr_reader :params

    def params=(params)
      @params = params || {}
      @select_fields = nil
      @created_at_gt = nil
      @created_at_lt = nil
    end

    def name
      params['name'].presence
    end

    def select_fields
      @select_fields ||= process_select_fields
    end

    def record_sum_gt
      params.dig('records_sum', 'gte')&.to_f
    end

    def record_sum_lt
      params.dig('records_sum', 'lte')&.to_f
    end

    def created_at_gt
      @created_at_gt ||= parse_date params.dig('created_name_at', 'gt')
    end

    def created_at_lt
      @created_at_lt ||= parse_date params.dig('created_name_at', 'lt')
    end

    def order_type
      type = params.dig('order', 'type')
      %w[asc desc].include?(type) ? type : 'asc'
    end

    def order_field
      field = params.dig('order', 'field')
      FEILDS_MAP.keys.push('name').include?(field) ? field : 'records.name'
    end

    private

    def process_select_fields
      return unless params['fields'].presence

      fields = extract_fields_str
      return unless fields.presence

      fields.insert(0, SELECT_SUBSTR)
    end

    def extract_fields_str
      params['fields']&.to_s&.split(',')
                      .tap { |fa| fa&.map! { |f| FEILDS_MAP[f] } }
                      .tap { |fa| fa&.compact! }&.join(', ') || ''
    end

    def parse_date(date_string)
      DateTime.parse(date_string)
    rescue StandardError
      nil
    end
  end
end
