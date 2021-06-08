# frozen_string_literal: true

require 'json_logic'

class Rule < ActiveRecord::Base
  RECORD_SAMPLE = { 'id' => 1, 'name' => 'name', 'amount' => -3.5, 'rest' => 100.00, 'performed_at' => Time.now,
                    'report_id' => nil, 'records_tags' => [], 'card' => { 'id' => '', 'name' => '' } }.freeze

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
end
