# frozen_string_literal: true

class FindRecordNames < RecordsGrouped
  def call(params)
    select_fields params['fields']
    filter_by_name params['name']
    filter_by_records_sum params['records_sum']
    filter_by_created_at params['created_name_at']
    order params
  end

  protected

  def default_relation
    Record.select(:name).group(:name)
  end

  def default_order
    @relation.order('records.name ASC')
  end

  def default_fields
    ['records.name'].freeze
  end

  def fields_map
    {
      'created_name_at' => 'min(records.created_at) as created_name_at',
      'records_sum' => 'sum(records.amount) as records_sum'
    }.freeze
  end

  def ordering_fields
    default_fields + fields_map.keys
  end

  def filter_by_name(name)
    @relation = @relation.where('name LIKE ?', "%#{name}%") if name
  end

  def filter_by_created_at(params)
    return unless params

    greater = parse_date(params['gt'])
    less = parse_date(params['lt'])

    @relation = @relation.having('min(records.created_at) > ?', greater) if greater
    @relation = @relation.having('min(records.created_at) < ?', less) if less
  end
end
