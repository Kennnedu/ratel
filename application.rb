require 'bundler'

Bundler.require(:default, ENV['APP_ENV'] || 'development')

Dotenv.load(File.expand_path("../.env.#{ENV['APP_ENV']}",  __FILE__))
Dotenv.load(File.expand_path("../.env",  __FILE__))

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

unless ENV['APP_ENV'].eql? 'test'
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end 

Dir[File.dirname(__FILE__) + '/app/**/*.rb'].each { |file| require file }
Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each { |file| require file }
