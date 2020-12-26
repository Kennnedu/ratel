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
    options = { except: %i[updated_at document_data user_id error_message] }.merge(options)

    super(options).merge(url: url, name: document['filename'])
  end

  def url
    if ENV['APP_ENV'].eql? 'development'
      "http://localhost:#{ENV['PORT']}/static#{document&.url}"
    else
      document&.url
    end
  end
end
