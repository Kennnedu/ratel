require_relative './api/cards_controller.rb'
require_relative './api/records_controller.rb'
require_relative './api/reports_controller.rb'
require_relative './api/tags_controller.rb'
require_relative './api/sessions_controller.rb'
require 'raddocs'

map('/api/v1/cards') { run CardsController.new }
map('/api/v1/records') { run RecordsController.new }
map('/api/v1/tags') { run TagsController.new }
map('/api/v1/reports') { run ReportsController.new }
map('/api/v1/sessions') { run SessionsController.new }
map('/api/docs') { run Raddocs::App}
