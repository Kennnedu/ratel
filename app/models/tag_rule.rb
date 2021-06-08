# frozen_string_literal: true

class TagRule < Rule
  belongs_to :tag

  validate :only_user_tags

  def action(record)
    record.records_tags.create(tag: tag)
  end

  def only_user_tags
    errors.add(:tag_id, 'isn\'t found') unless user.tags.pluck(:id).include?(tag_id)
  end
end
