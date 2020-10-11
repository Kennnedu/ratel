# frozen_string_literal: true

class CreateBulkRecord
  def initialize
    @iterator = ReportIterator.new
  end

  def process(user, report, rec_opt = {})
    ActiveRecord::Base.transaction do
      @iterator.foreach(report) do |record_attr|
        card = user.cards.find_or_create_by(name: record_attr['card'])
        record_attr.delete :card
        user.records.find_or_create_by(record_attr.merge(card: card).merge(rec_opt))
      end
    end
  end
end
