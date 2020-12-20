# frozen_string_literal: true

module Services
  class FetchGmailReports
    USER_ID = 'me'

    include Import['gmail_api', 'services.authorize_gmail_connection']

    def process(user)
      authorize(user.gmail_connection)

      (gmail_api.list_user_messages(USER_ID, q: user.gmail_connection.q).messages || []).each do |message|
        save_report(user.reports.build, *fetch_data_report(message))
      end

      user.gmail_connection.update_attribute 'connected_at', Time.now
    end

    private

    def authorize(connection)
      credentials = authorize_gmail_connection.process connection

      raise 'Not authorized connection' unless credentials

      gmail_api.authorization = credentials
    end

    def fetch_data_report(message)
      last_message_part = gmail_api.get_user_message(USER_ID, message.id).payload.parts.last
      attachment_id = last_message_part.body.attachment_id
      [gmail_api.get_user_message_attachment(USER_ID, message.id, attachment_id).data, last_message_part.filename]
    end

    def save_report(new_report, data, filename = '')
      tmp = Tempfile.new filename
      tmp.write data
      tmp.rewind
      new_report.document = tmp
      new_report.save!
    ensure
      tmp.close
      tmp.unlink
    end
  end
end
