require 'bundler/setup'
require 'dotenv'
require 'jwt'
require 'nokogiri'

begin
  require 'byebug'
rescue LoadError
end

Dotenv.load(".env.#{ENV['APP_ENV'] || 'development'}")
Dotenv.load('.env')

require_relative 'container'
require_relative 'import'


if ENV['APP_ENV'].eql?('production')
  require 'scout_apm'

  ScoutApm::Rack.install!
end

Container.finalize!


