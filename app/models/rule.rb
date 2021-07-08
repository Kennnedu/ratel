# frozen_string_literal: true

require 'json_logic'

class Rule < ActiveRecord::Base
  RECORD_SAMPLE = { 'name' => 'name', 'amount' => -3.5,
                    'card' => { 'id' => '', 'name' => '' } }.freeze

  belongs_to :user

  validates :condition, :name, :type, :user_id, presence: true
  validate :valid_condition?

  def apply_for(record)
    return unless JSONLogic.apply(condition, record.as_json)

    action record
  end

  def action(record); end

  def valid_condition?
    JSONLogic.apply(condition, RECORD_SAMPLE)
  rescue StandardError => e
    errors.add(:condition, e.message)
  end

  def as_json(options = {})
    super(options).merge(type: type)
  end
end
