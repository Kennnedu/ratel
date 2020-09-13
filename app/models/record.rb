# frozen_string_literal: true

class Record < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :card
  belongs_to :report
  has_many :records_tags, dependent: :destroy
  has_many :tags, through: :records_tags

  validates :name, :amount, :performed_at, presence: true

  scope :only_keywords, ->(column, keywords) { where("#{column} LIKE ANY (array[?])", keywords) }
  scope :except_keywords, ->(column, keywords) { where.not("#{column} LIKE ANY (array[?])", keywords) }
  scope :greater_amount, ->(amount) { where('records.amount > ?', amount) }
  scope :less_amount, ->(amount) { where('records.amount < ?', amount) }
  scope :greater_performed_at, ->(performed_at) { where('records.performed_at > ?', performed_at) }
  scope :less_performed_at, ->(performed_at) { where('records.performed_at < ?', performed_at) }
  scope :recent, -> { order('records.performed_at desc') }

  before_validation :set_performed_at, unless: :performed_at

  accepts_nested_attributes_for :records_tags, allow_destroy: true

  def set_performed_at
    self.performed_at = DateTime.current
  end

  def as_json(options = {})
    options = {
      except: %i[created_at updated_at user_id card_id],
      include: {
        card: { only: %i[name id] },
        records_tags: { only: %i[id tag_id], include: { tag: { only: %i[id name] } } }
      }
    }.merge(options)

    return super(options) if options[:include][:card] && card

    super(options).merge(card: { id: '', name: '' })
  end
end
