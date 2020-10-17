# frozen_string_literal: true

class TagsParams
  SELECT_SUBSTR = 'tags.id, tags.name, '
  FEILDS_MAP = {
    'created_at' => 'tags.created_at',
    'updated_at' => 'tags.updated_at',
    'records_sum' => 'coalesce(sum(records.amount), 0) as records_sum'
  }.freeze

  attr_reader :params

  def params=(params)
    @params = params || {}
    @select_fields = nil
  end

  def select_fields
    @select_fields ||= process_select_fields
  end

  def name
    params['name'].presence
  end

  def record_params
    params['record'].presence || {}
  end

  def record_sum_gt
    params.dig('records_sum', 'gte')&.to_f
  end

  def record_sum_lt
    params.dig('records_sum', 'lte')&.to_f
  end

  def join_records?
    params['fields']&.include?('records_sum')
  end

  def order_type
    type = params.dig('order', 'type')
    %w[asc desc].include?(type) ? type : 'desc'
  end

  def order_field
    field = params.dig('order', 'field')
    ordering_fields.include?(field) ? field : 'tags.created_at'
  end

  private

  def ordering_fields
    (Tag.column_names + FEILDS_MAP.keys).uniq
  end

  def process_select_fields
    return unless params['fields'].presence

    fields = params['fields']&.to_s&.split(',')&.map! { |f| FEILDS_MAP[f] }
    fields&.compact!
    fields = (fields || []).join(', ')
    return unless fields.presence

    fields.insert(0, SELECT_SUBSTR)
  end
end
