require_relative 'system/boot'
require 'raddocs'

map('/api/v1/cards') { run Container['api.cards_controller'] }
map('/api/v1/records') { run Container['api.records_controller'] }
map('/api/v1/tags') { run Container['api.tags_controller'] }
map('/api/v1/reports') { run Container['api.reports_controller'] }
map('/api/v1/sessions') { run Container['api.sessions_controller'] }
map('/api/docs') { run Raddocs::App}
