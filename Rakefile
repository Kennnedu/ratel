require 'sinatra/activerecord/rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = './api/tests/**/*_test.rb'
end

namespace :db do
  task :load_config do
    require './application.rb'
  end
end
