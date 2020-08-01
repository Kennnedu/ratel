# frozen_string_literal: true

class Card < ActiveRecord::Base
  belongs_to :user, required: true
  has_many :records

  validates_presence_of :name

  scope :join_record_query, lambda { |query|
    joins("left join (#{query}) records on cards.id = records.card_id")
      .group('cards.id')
  }
end
