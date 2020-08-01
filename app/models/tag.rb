# frozen_string_literal: true

class Tag < ActiveRecord::Base
  belongs_to :user, required: true
  has_many :records_tags, dependent: :destroy
  has_many :records, through: :records_tags

  # validates :name, :user_id, uniqueness: true, presence: true

  scope :join_record_query, lambda { |query|
    joins('left join records_tags on records_tags.tag_id = tags.id')
      .joins("left join (#{query}) records on records_tags.record_id = records.id")
      .group('tags.id')
  }
end
