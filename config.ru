require_relative './system/boot'
require 'raddocs'

if ENV['APP_ENV'].eql?('production')
  require 'scout_apm'

  ScoutApm::Rack.install!
end

map('/api/v1/rules') { run Container['api.rules_controller'] }
map('/api/v1/cards') { run Container['api.cards_controller'] }
map('/api/v1/records') { run Container['api.records_controller'] }
map('/api/v1/tags') { run Container['api.tags_controller'] }
map('/api/v1/reports') { run Container['api.reports_controller'] }
map('/api/v1/sessions') { run Container['api.sessions_controller'] }
map('/api/v1/user') { run Container['api.users_controller'] }
map('/api/v1/oauth2/gmail') { run Container['api.oauth2_gmail_controller']  }
map('/static') { run Container['statics'] }
map('/api/docs') { run Raddocs::App }
map '/sidekiq' do
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking
    Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
    Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  end

  run Sidekiq::Web
end
