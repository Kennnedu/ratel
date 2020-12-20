# frozen_string_literal: true

module Services
  class AuthorizeGmailConnection
    include Import['google_auth']

    def process(connection)
      credentials = google_auth.get_credentials connection.id.to_s

      if credentials
        connection.update_attribute('connected', true)
        credentials
      else
        connection.update_attribute('connected', false)
        nil
      end
    end
  end
end
