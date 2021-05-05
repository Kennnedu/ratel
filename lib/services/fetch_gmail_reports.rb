# frozen_string_literal: true

module Services
  class FetchGmailReports
    USER_ID = 'me'

    include Import['gmail_api', 'services.authorize_gmail_connection', 'logger']

    def process(user)
      authorize(user.gmail_connection)

      fetch_messages(user.gmail_connection).each do |message|
        data_report = fetch_data_report(user.gmail_connection, message)
        save_report(user.reports.build, *data_report) if data_report.presence
      end

      user.gmail_connection.update_attribute 'connected_at', Time.now
    rescue StandardError => e
      logger.fatal e
    end

    private

    def authorize(connection)
      logger.info "Process #{connection.inspect}"

      credentials = authorize_gmail_connection.process connection

      raise 'Not authorized connection' unless credentials

      gmail_api.authorization = credentials
    end

    def fetch_messages(gmail_connection)
      gmail_api.list_user_messages(USER_ID, q: gmail_connection.q).messages || []
    end

    def fetch_data_report(gmail_connection, message)
      msg = gmail_api.get_user_message(USER_ID, message.id)

      if gmail_connection.report_sender.eql?('info@belinvestbank.by')
        return [msg.payload.parts[0].body.data, "#{Time.now.to_i.to_s}.htm"] if msg.payload.parts.presence
      else
        last_message_part = msg.payload.parts.last
        attachment_id = last_message_part.body.attachment_id
        return [gmail_api.get_user_message_attachment(USER_ID, message.id, attachment_id).data, last_message_part.filename]
      end
    end

    def save_report(new_report, data, filename)
      tmp = Tempfile.new
      tmp.write data
      tmp.rewind
      filename ||= File.basename tmp
      new_report.document = { filename: filename, tempfile: tmp, name: 'document' }
      new_report.save!
    ensure
      tmp.close
      tmp.unlink
    end
  end
end
