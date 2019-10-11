class RecordsTag < ActiveRecord::Base
  belongs_to :record
  belongs_to :tag
end