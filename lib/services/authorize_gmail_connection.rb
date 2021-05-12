# frozen_string_literal: true

module Services
  class AuthorizeGmailConnection
    include Import['gmail_api', 'google_auth', 'logger']

    def process(connection)
      credentials = google_auth.get_credentials connection.id.to_s
      logger.info "Authorizing #{connection.inspect}"

      if credentials
        connection.update_attribute('connected', true)
        gmail_api.authorization = credentials
        gmail_api
      else
        connection.update_attribute('connected', false)
        raise 'Not authorized connection'
      end
    end
  end
end
