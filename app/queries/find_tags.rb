# frozen_string_literal: true

class FindTags < RecordsGrouped
  def call(params, user)
    select_fields params['fields']

    if params['fields'].include?('records_sum')
      joins_records(params['record'], user)
      filter_by_records_sum(params['records_sum'])
    end

    order params['order']
  end

  protected

  def default_relation
    Tag.all
  end

  def default_order
    @relation.order('created_at DESC')
  end

  def default_fields
    ['tags.id', 'tags.name'].freeze
  end

  def fields_map
    {
      'created_at' => 'tags.created_at',
      'updated_at' => 'tags.updated_at',
      'records_sum' => 'coalesce(sum(records.amount), 0) as records_sum'
    }.freeze
  end

  def joins_records(record_params, user)
    @relation = @relation.joins('left join records_tags on records_tags.tag_id = tags.id')
                         .joins("left join (#{filtered_records_sql(record_params, user)}) records on \
                                records_tags.record_id = records.id")
                         .group('tags.id')
  end

  def filter_by_tagname(tagname)
    @relation = @relation.where('tags.name LIKE ?', "%#{tagname}%") if tagname
  end
end
