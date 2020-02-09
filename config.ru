require_relative './app/app'
require_relative './api/api_v1'

map('/') { run AppController }
map('/api/v1') { run ApiV1Controller }