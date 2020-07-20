require_relative './api/api'
require 'raddocs'

map('/api') { run ApiController }
map('/api/docs') { run Raddocs::App }
