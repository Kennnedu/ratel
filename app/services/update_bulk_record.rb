# frozen_string_literal: true

class UpdateBulkRecord
  def process(user, params)
    record_query = FindRecords.new(user.records).call(params)
    batch_form = params['batch_form'].presence
    removing_tag_ids = params['removing_tag_ids'].presence

    ActiveRecord::Base.transaction do
      record_query.find_each(batch_size: 30) { |record| record.update!(batch_form) } if batch_form

      if removing_tag_ids.presence
        RecordsTag .joins("INNER JOIN (#{record_query.to_sql}) rec ON rec.id = records_tags.record_id")
                   .where(tag_id: removing_tag_ids).destroy_all
      end

    rescue Exception => e
      e.message
    end
  end
end
