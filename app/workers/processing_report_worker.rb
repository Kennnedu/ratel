# frozen_string_literal: true

require_relative './../../application.rb'

class ProcessingReportWorker
  include Sidekiq::Worker

  def perform(id)
    report = Report.find id

    ActiveRecord::Base.transaction do
      CreateBulkRecord.new.process(report.user, report.document.open, report: report)
      report.update(status: 1)
    end
  rescue StandardError => e
    report.update(status: 2, error_message: e)
  end
end
