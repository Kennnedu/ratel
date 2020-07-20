# frozen_string_literal: true

class Card < ActiveRecord::Base
  belongs_to :user, required: true

  validates_presence_of :name
end
