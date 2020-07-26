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
    @relation = if params && valid_order_params?(params)
                  @relation.order("#{params['field'].downcase} #{params['type'].downcase}")
                else
                  default_order
                end
  end

  def valid_order_params?(params)
    ORDER_TYPES.include?(params['type']) && ordering_fields.include?(params['field'])
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
