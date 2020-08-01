# frozen_string_literal: true

class FindCards < RecordsGrouped
  def call(params, user)
    select_fields params['fields']

    if params['fields']&.include?('records_sum')
      joins_records(params['record'], user)
      filter_by_records_sum(params['records_sum'])
    end

    order params
  end

  protected

  def default_relation
    Card.all
  end

  def default_order
    @relation.order('cards.created_at DESC')
  end

  def default_fields
    %w[cards.id cards.name].freeze
  end

  def fields_map
    {
      'created_at' => 'cards.created_at',
      'updated_at' => 'cards.updated_at',
      'records_sum' => 'coalesce(sum(records.amount), 0) as records_sum'
    }.freeze
  end

  def joins_records(records_params, user)
    @relation = @relation.join_record_query(filtered_records_sql(records_params, user))
  end
end
