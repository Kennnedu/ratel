class Record < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :card
  has_many :records_tags, dependent: :destroy
  has_many :tags, through: :records_tags

  before_validation :set_performed_at, unless: :performed_at

  # validates :name, :amount, :performed_at, :user_id, uniqueness: true, presence: true

  accepts_nested_attributes_for :records_tags, allow_destroy: true

  def as_json
    result = super(except: [:created_at, :updated_at, :user_id, :card_id],
                   include: { card: { only: [:name, :id]},
                              records_tags: { only: [:id, :tag_id],
                                              include: { tag: { only: [:id, :name]}}}})
    return result if card
    result.merge(card: Card.new(id: 0, name: '').as_json(only: [:name, :id]))
  end

  def set_performed_at
    self.performed_at = DateTime.current
  end
end