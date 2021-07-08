# frozen_string_literal: true

Container.boot(:activerecord) do |app|
  init do
    use :shrine
    use :logger

    require 'sinatra/activerecord'

    ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL'))
    ActiveRecord::Base.logger = app['logger'] unless ENV['APP_ENV'].eql? 'test'

    app.require_from_root('app/models/rule')
    app.require_from_root('app/models/*')
  end
end
