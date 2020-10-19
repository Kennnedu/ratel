# frozen_string_literal: true

Container.boot(:activerecord) do
  init do
    use :shrine

    require 'sinatra/activerecord'

    ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
    ActiveRecord::Base.logger = Logger.new(STDOUT) unless ENV['APP_ENV'].eql? 'test'

    Dir[File.dirname(__FILE__) + '/../../app/models/*.rb'].each { |file| require file }
  end
end
