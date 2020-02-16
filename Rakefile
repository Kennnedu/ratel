require "sinatra/activerecord/rake"
require 'rake/testtask'
require 'rspec/core/rake_task'

desc 'Generate API request documentation from API specs'
RSpec::Core::RakeTask.new('docs:generate') do |t|
  t.pattern = 'api/specs/acceptance/**/*_spec.rb'
  t.rspec_opts = ["--format RspecApiDocumentation::ApiFormatter"]
end

Rake::TestTask.new do |t|
  t.pattern = "./api/tests/**/*_test.rb"
end

namespace :db do
  task :load_config do
    require './api/api'
  end
end
