# frozen_string_literal: true

class Tag < ActiveRecord::Base
  belongs_to :user, required: true
  has_many :records_tags, dependent: :destroy
  has_many :records, through: :records_tags

  validates :name, uniqueness: { scope: :user_id }
  validates :name, presence: true

  scope :join_record_query, lambda { |query|
    joins('left join records_tags on records_tags.tag_id = tags.id')
      .joins("left join (#{query}) records on records_tags.record_id = records.id")
      .group('tags.id')
  }

  before_validation :prepare_name

  def prepare_name
    self.name = name.strip.downcase
  end
end
