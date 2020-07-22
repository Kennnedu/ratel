require_relative './api/api'
require 'raddocs'

map('/api/v1') { run ApiController }
map('/api/docs') { run Raddocs::App }
