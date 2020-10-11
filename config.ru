require_relative './api/card_controller.rb'
require_relative './api/record_controller.rb'
require_relative './api/report_controller.rb'
require_relative './api/tag_controller.rb'
require_relative './api/session_controller.rb'
require 'raddocs'

map('/api/v1/cards') { run CardController.new }
map('/api/v1/records') { run RecordController.new }
map('/api/v1/tags') { run TagController.new }
map('/api/v1/reports') { run ReportController.new }
map('/api/v1/sessions') { run SessionController.new }
map('/api/docs') { run Raddocs::App}
