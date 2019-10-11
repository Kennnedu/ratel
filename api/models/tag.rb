class Tag < ActiveRecord::Base
  belongs_to :user, required: true
  has_many :records_tags, dependent: :destroy
  has_many :records, through: :records_tags

  # validates :name, :user_id, uniqueness: true, presence: true
end