require 'sinatra/activerecord/rake'
require 'rake/testtask'
require_relative './system/boot'

Rake::TestTask.new do |t|
  t.pattern = './api/tests/**/*_test.rb'
end

namespace :db do
  task :load_config do
  end
end

namespace :currency_db do
  task :load_config do
    ENV['SCHEMA'] = 'db/currency_schema.rb'
    ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_CURRENCY_URL'))
    ActiveRecord::Base.configurations = { "#{ENV['APP_ENV']}" => ActiveRecord::Base.connection_config.transform_keys(&:to_s) }
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = ['db/currency_migrate']
    ActiveRecord::Migrator.migrations_paths = ['db/currency_migrate']
  end

  task create: :load_config do
    Rake::Task['db:create'].invoke
  end

  task drop: :load_config do
    Rake::Task['db:drop'].invoke
  end

  task migrate: :load_config do
    Rake::Task['db:migrate'].invoke
  end

  task rollback: :load_config do
    Rake::Task['db:rollback'].invoke
  end

  task create_migration: :load_config do
    Rake::Task['db:create_migration'].invoke
  end
end

namespace :currency do
  desc 'Populate currency data'

  task :populate do
    resp = Faraday.get("https://apilayer.net/api/live?access_key=#{ENV['CURRENCYLAYER_KEY']}&currencies=EUR,BYN,PLN&source=USD")
    data = JSON.parse(resp.body)

    Usd.create(
      byn: data.dig('quotes', 'USDBYN'),
      pln: data.dig('quotes', 'USDPLN'),
      eur: data.dig('quotes', 'USDEUR')
    )
  end
end

namespace :gmail_reports do
  desc 'Fetch reports from gmail account'
  task :fetch do
    fetcher = Container['services.fetch_gmail_reports']

    User.joins(:gmail_connection).find_each(batch_size: 30) { |user| fetcher.process user }
  end
end

