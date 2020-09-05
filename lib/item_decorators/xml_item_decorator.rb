# frozen_string_literal: true

require_relative 'base_item_decorator'

class XmlItemDecorator < BaseItemDecorator
  REPLENISH_TYPE = 'Получение средств'

  def card
    nil
  end

  def name
    __getobj__.css('field')[7].text
  end

  def amount
    amount = __getobj__.css('field')[4].text.gsub(',', '.').to_f
    return amount * -1 unless replenish?

    amount
  end

  def performed_at
    DateTime.parse __getobj__.css('field')[1].text
  end

  private

  def replenish?
    __getobj__.css('field')[2].text.eql? REPLENISH_TYPE
  end
end
