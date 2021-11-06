# frozen_string_literal: true

class ProcessingReportWorker
  include Import['report_iterator.report_iterator']
  include Sidekiq::Worker

  def perform(id)
    report = Report.find id

    ActiveRecord::Base.transaction do
      report_iterator.foreach(report) do |record_attr|
        process_item(report, record_attr)
      end

      report.update(status: 1)
    end
  rescue StandardError => e
    report.update(status: 2, error_message: e)
  end

  private

  def process_item(report, attr)
    card = report.user.cards.find_or_create_by(name: attr['card'])
    attr.delete 'card'
    report.user.records.find_or_create_by(attr.merge(card: card).merge(report_id: report.id))
  end
end
