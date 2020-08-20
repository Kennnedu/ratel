# frozen_string_literal: true

require_relative 'base_item_decorator'

class HtmlItemDecorator < BaseItemDecorator
  attr_accessor :card

  def name
    __getobj__.css('td')[3].content
  end

  def amount
    amt = __getobj__.css('td')[6].content.gsub(',', '.').to_f

    return amt if replenish?

    amt * -1
  end

  def performed_at
    @last_peformed_at = DateTime.parse(__getobj__.css('td')[0].text.strip).to_s
  rescue StandardError
    @last_peformed_at ||= Time.now
  end

  private

  def replenish?
    __getobj__.css('td')[6].content.include? '+'
  end
end
