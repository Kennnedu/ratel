# frozen_string_literal: true

module Services
  class FetchGmailReports
    USER_ID = 'me'
    BELINVEST_INFO_SENDER = 'info@belinvestbank.by'

    include Import['logger', 'services.authorize_gmail_connection', { 'onesignal': 'onesignal.client' }]

    attr_accessor :new_reports, :gmail_api, :user

    def process(user)
      reset_state(user)

      fetch_messages.each do |message|
        data_report = fetch_data_report(message)
        save_report(user.reports.build, *data_report) if data_report.presence
      end

      after_porcess
    rescue StandardError => e
      logger.fatal e
    end

    private

    def reset_state(user)
      self.user = user || raise('User not found')
      self.new_reports = []
      self.gmail_api = authorize_gmail_connection.process(user.gmail_connection)
    end

    def fetch_messages
      gmail_api.list_user_messages(USER_ID, q: user.gmail_connection.q).messages || []
    end

    def fetch_data_report(message)
      msg = gmail_api.get_user_message(USER_ID, message.id)

      if user.gmail_connection.report_sender.eql?(BELINVEST_INFO_SENDER)
        fetch_table_data msg
      else
        fetch_attachment_data message.id, msg
      end
    end

    def fetch_table_data(msg)
      [msg.payload.parts[0].body.data, "#{Time.now.to_i}.htm"] if msg.payload.parts.presence
    end

    def fetch_attachment_data(msg_id, msg)
      last_message_part = msg.payload.parts.last
      attachment_id = last_message_part.body.attachment_id
      [gmail_api.get_user_message_attachment(USER_ID, msg_id, attachment_id).data, last_message_part.filename]
    end

    def save_report(new_report, data, filename)
      tmp = Tempfile.new
      tmp.write data
      tmp.rewind
      filename ||= File.basename tmp
      new_report.document = { filename: filename, tempfile: tmp, name: 'document' }
      new_report.save!
      new_reports << new_report
    ensure
      tmp.close
      tmp.unlink
    end

    def after_porcess
      user.gmail_connection.update_attribute 'connected_at', Time.now

      onesignal.create_notification(user.username, 'New reports was fetched from your mailbox.') if new_reports.present?
    end
  end
end
