require_relative 'base_row_decorator'

class BelinvestRowDecorator < BaseRowDecorator
  def name
    is_replenish ? 'REPLENISHMENT' : __getobj__.css('td')[4].content.squish.gsub("\"", '')
  end

  def card
    __getobj__.css('td')[2].content
  end

  def amount
    __getobj__.css('td')[is_replenish ? 6 : 5].content.gsub(/BYN|\s/, '').gsub(',', '.').to_f
  end

  def rest
    is_replenish ? 0.0 : __getobj__.css('td')[7].content.gsub(/BYN|\s/, '').gsub(',', '.').to_f
  end

  def performed_at
    DateTime.parse(__getobj__.css('td')[0].content).to_s
  end

  private

  def is_replenish
    __getobj__.css('td')[5].content.gsub(/BYN|\s/, '').gsub(',', '.').to_f.eql? 0.0
  end
end