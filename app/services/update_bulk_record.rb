# frozen_string_literal: true

class UpdateBulkRecord
  def initialize(query, params, remove_tag_ids)
    @record_query = query
    @params = params.presence
    @remove_tag_ids = remove_tag_ids.presence
  end

  def process
    ActiveRecord::Base.transaction do
      @record_query.find_each(batch_size: 30) { |record| record.update!(@params) } if @params

      if @remove_tag_ids
        RecordsTag .joins("INNER JOIN (#{@record_query.to_sql}) rec ON rec.id = records_tags.record_id")
                   .where(tag_id: @remove_tag_ids).destroy_all
      end
    end
  end
end
