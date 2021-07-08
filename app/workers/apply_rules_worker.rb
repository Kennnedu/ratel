# frozen_string_literal: true

require 'json_logic'

class ApplyRulesWorker
  include Sidekiq::Worker

  def perform(id)
    record = Record.find id
    rules = record.user.rules
    rules.each { |rule| rule.apply_for(record) }
  end
end
