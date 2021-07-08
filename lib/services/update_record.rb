# frozen_string_literal: true

module Services
  class UpdateRecord
    # TODO: not used try to integrate
    def process(record, params)
      @record = record
      @tags = params.delete('tags')
      assign_tags
      @record.assign_attributes params
      @record.save
    end

    private

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def assign_tags
      return unless @tags

      tags_attr = []
      all_tags = @record.user.tags.map(&:name)
      record_tags = @record.tags.map(&:name)

      create_and_set = @tags - all_tags
      set_tags = (@tags & all_tags) - record_tags
      remove_tags = record_tags - @tags

      create_and_set.each do |tag|
        tag_obj = @record.user.tags.create name: tag
        tags_attr << { tag_id: tag_obj.id }
      end

      set_tags.each do |tag|
        tag_obj = @record.user.tags.find_by_name tag
        tags_attr << { tag_id: tag_obj.id }
      end

      remove_tags.each do |tag|
        tag_obj = @record.user.tags.find_by_name tag
        rec_tag = @record.records_tags.find_by_tag_id tag_obj.id
        tags_attr << { id: rec_tag.id, _destroy: 1 }
      end

      @record.records_tags_attributes = tags_attr
    end
    # rubocop:enable all
  end
end
