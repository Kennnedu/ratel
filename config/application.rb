require 'bundler'

Bundler.require(:default, ENV['APP_ENV'] || 'development')

Dotenv.load

ActiveRecord::Base.logger = Logger.new(STDOUT)

Dir[File.dirname(__FILE__) + '/../app/**/*.rb'].each { |file| require file }
Dir[File.dirname(__FILE__) + '/../lib/**/*.rb'].each { |file| require file }
