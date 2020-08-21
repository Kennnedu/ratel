# frozen_string_literal: true

class RecordsTag < ActiveRecord::Base
  belongs_to :record
  belongs_to :tag

  validates :record_id, uniqueness: { scope: :tag_id }
end
