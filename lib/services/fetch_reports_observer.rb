# frozen_string_literal: true

module Services
  class FetchReportsObserver
    include Import[{ 'onesignal': 'onesignal.client' }]

    def update(user, new_reports)
      user.gmail_connection.update_attribute 'connected_at', Time.now

      onesignal.create_notification(user.username, 'New reports was fetched from your mailbox.') if new_reports.present?
    end
  end
end
