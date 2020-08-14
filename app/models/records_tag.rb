# frozen_string_literal: true

class RecordsTag < ActiveRecord::Base
  belongs_to :record
  belongs_to :tag
end
