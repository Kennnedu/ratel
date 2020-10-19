require 'bundler/setup'
require 'dotenv'
require 'jwt'
require 'nokogiri'

begin
  require 'byebug'
rescue
end

Dotenv.load(".env.#{ENV['APP_ENV'] || 'development'}")
Dotenv.load('.env')

require_relative 'container'
require_relative 'import'

Container.finalize!


