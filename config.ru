require_relative './app/app'
require_relative './api/api'

map('/') { run AppController }
map('/api') { run ApiController }