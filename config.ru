require_relative './api/api_v1'
require 'raddocs'

map('/api/v1') { run ApiV1Controller }
map('/api/docs') { run Raddocs::App }