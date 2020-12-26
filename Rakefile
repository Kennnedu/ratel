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

namespace :gmail_reports do
  desc 'Fetch reports from gmail account'
  task :fetch do
    fetcher = Container['services.fetch_gmail_reports']

    User.joins(:gmail_connection).find_each(batch_size: 30) { |user| fetcher.process user }
  end
end

