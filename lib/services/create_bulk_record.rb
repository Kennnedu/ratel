# frozen_string_literal: true

require 'import'

module Services
  class CreateBulkRecord
    include Import['report_iterator.report_iterator']

    def process(user, report, rec_opt = {})
      ActiveRecord::Base.transaction do
        report_iterator.foreach(report) do |record_attr|
          card = user.cards.find_or_create_by(name: record_attr['card'])
          record_attr.delete :card
          user.records.find_or_create_by(record_attr.merge(card: card).merge(rec_opt))
        end
      end
    end
  end
end
