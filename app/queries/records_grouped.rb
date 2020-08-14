# frozen_string_literal: true

class RecordsGrouped < BaseQuery
  protected

  def default_fields
    raise NotImplementedError
  end

  def fields_map
    raise NotImplementedError
  end

  def select_fields(params_fields)
    return unless params_fields

    @relation = @relation.unscope(:select).select(fields_string(params_fields))
  end

  def filter_by_records_sum(params)
    greater = params&.dig('gte')&.to_f
    less = params&.dig('lte')&.to_f

    @relation = @relation.having('coalesce(sum(records.amount), 0) > ?', greater) if greater
    @relation = @relation.having('coalesce(sum(records.amount), 0) < ?', less) if less
  end

  def filtered_records_sql(params_record, user)
    FindRecords.new(user&.records).call(params_record || {}).to_sql
  end

  def fields_string(params_fields)
    (default_fields + (params_fields&.to_s&.split(',')&.map { |f| fields_map[f] }&.compact || [])).join(', ')
  end

  def valid_order_params?(params)
    return super(params) unless fields_map.keys.include?(params.dig('order', 'field'))

    super(params) && params['fields']&.include?(params['order']['field'])
  end

  def ordering_fields
    (super + fields_map.keys).uniq
  end
end
