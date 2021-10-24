source 'https://rubygems.org'

ruby '2.6.6'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }
# The bcrypt Ruby gem provides a simple wrapper for safely handling passwords.
gem 'bcrypt'
# Bugsnag error monitoring & reporting software for rails, sinatra, rack and ruby
gem 'bugsnag', '~> 6.17'
# A Ruby gem to load environment variables from `.env`.
gem 'dotenv'
# Organize your code into reusable components
gem 'dry-system', '~> 0.18.1'
# Simple, but flexible HTTP client library, with support for multiple backends.
gem 'faraday', '~> 0.17.3'
# A ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard.
gem 'jwt'
# Build complex rules, serialize them as JSON, and execute them in ruby
gem 'json_logic', '~> 0.4.7'
# Nokogiri is a Rubygem providing HTML, XML, SAX, and Reader parsers with XPath and CSS selector support.
gem 'nokogiri'
# New Relic RPM Ruby Agent
gem 'newrelic_rpm'
# The 'pg' Ruby library, an interface to the PostgreSQL Relational Database Management System.
gem 'pg'
# Rspec Api Documentation Browser
gem 'raddocs'
# A make-like build utility for Ruby. https://ruby.github.io/rake
gem 'rake'
# Restarts an app when the filesystem changes. Uses growl and FSEventStream if on OS X.
gem 'rerun', '~> 0.13.1'
# File Attachment toolkit for Ruby applications
gem 'shrine'
# Google Drive Storage for Shrine
gem 'shrine-gdrive_storage', git: 'https://github.com/Kennnedu/shrine-gdrive_storage.git'
# Simple, efficient background processing for Ruby
gem 'sidekiq'
# Classy web-development dressed in a DSL (official / canonical repo) http://www.sinatrarb.com/
gem 'sinatra'
# Extends Sinatra with ActiveRecord helper methods and Rake tasks.
gem 'sinatra-activerecord'
# Collection of common Sinatra extensions, semi-officially supported.
gem 'sinatra-contrib'

group :development, :test do
  # Debugging in Ruby 2
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # A library for setting up Ruby objects as test data. https://thoughtbot.com/open-source
  gem 'factory_bot'
  # A library for generating fake data such as names, addresses, and phone numbers.
  gem 'faker', git: 'https://github.com/faker-ruby/faker.git', branch: 'master'
end

group :test do
  # Strategies for cleaning databases in Ruby. Can be used to ensure a clean state for testing.
  gem 'database_cleaner-active_record'
  # RSpec meta-gem that depends on the other components
  gem 'rspec'
  # Automatically generate API documentation from RSpec
  gem 'rspec_api_documentation', '~> 6.1'
  # Create customizable MiniTest output formats.
  gem 'minitest-reporters'
  # Rack::Test is a layer on top of Rack's MockRequest similar to Merb's RequestHelper
  gem 'rack-test'
end

gem 'rubocop', '~> 0.93.1', :group => :development, require: false
