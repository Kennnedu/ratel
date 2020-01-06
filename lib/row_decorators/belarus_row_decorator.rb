require_relative 'base_row_decorator'

class BelarusRowDecorator < BaseRowDecorator
  attr_accessor :card

  def name
    __getobj__.css('td')[3].content
  end

  def amount
    amt = __getobj__.css('td')[6].content.to_f

    return amt if is_replenish

    amt * -1
  end

  def performed_at
    DateTime.parse(__getobj__.css('td')[0].text.strip).to_s
  end

  private

  def is_replenish
    __getobj__.css('td')[6].content.include? '+'
  end
end
