require_relative './app/app'
require_relative './api/api_v1'
require 'raddocs'

map('/') { run AppController }
map('/api/v1') { run ApiV1Controller }
map('/api/docs') { run Raddocs::App }