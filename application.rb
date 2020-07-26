require 'bundler'

Bundler.require(:default, ENV['APP_ENV'] || 'development')

Dotenv.load(File.expand_path("../.env.#{ENV['APP_ENV']}.local",  __FILE__))
Dotenv.load(File.expand_path("../.env.local",  __FILE__))

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

unless ENV['APP_ENV'].eql? 'test'
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end 

require_relative 'app/queries/base_query'
require_relative 'app/queries/records_grouped'

Dir[File.dirname(__FILE__) + '/app/**/*.rb'].each { |file| require file }
Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each { |file| require file }
