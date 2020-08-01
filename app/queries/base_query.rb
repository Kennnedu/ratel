# frozen_string_literal: true

class BaseQuery
  ORDER_TYPES = %w[desc asc].freeze

  attr_reader :relation

  def initialize(relation = default_relation)
    @relation = relation
  end

  def call
    raise NotImplementedError
  end

  protected

  def default_relation
    raise NotImplementedError
  end

  def default_order
    raise NotImplementedError
  end

  def order(params)
    @relation = if valid_order_params?(params)
                  @relation.order("#{params['order']['field'].downcase} #{params['order']['type'].downcase}")
                else
                  default_order
                end
  end

  def valid_order_params?(params)
    params['order'] && ORDER_TYPES.include?(params['order']['type']) && ordering_fields.include?(params['order']['field'])
  end

  def ordering_fields
    default_relation.column_names
  end

  def parse_date(date_string)
    DateTime.parse(date_string)
  rescue StandardError
    nil
  end
end
