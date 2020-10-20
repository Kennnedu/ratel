# frozen_string_literal: true

class ProcessingReportWorker
  include Import['services.create_bulk_record']
  include Sidekiq::Worker

  def perform(id)
    report = Report.find id

    ActiveRecord::Base.transaction do
      create_bulk_record.process(report.user, report.document.open, report: report)
      report.update(status: 1)
    end
  rescue StandardError => e
    report.update(status: 2, error_message: e)
  end
end
