# frozen_string_literal: true

class Report < ActiveRecord::Base
  include Shrine::Attachment(:document)

  belongs_to :user
  has_many :records, dependent: :destroy

  enum status: %i[queue processed error]

  after_create do
    ProcessingReportWorker.perform_async(id)
  end

  def as_json(options = {})
    options = { except: %i[updated_at document_data] }.merge(options)

    super(options).merge(document_url: document&.url)
  end
end
