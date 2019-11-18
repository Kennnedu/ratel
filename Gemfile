# frozen_string_literal: true

source "https://rubygems.org"

ruby '2.6.0'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }
# The bcrypt Ruby gem provides a simple wrapper for safely handling passwords.
gem 'bcrypt'
# A Ruby gem to load environment variables from `.env`.
gem 'dotenv'
# A ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard.
gem 'jwt'
# Nokogiri is a Rubygem providing HTML, XML, SAX, and Reader parsers with XPath and CSS selector support.
gem 'nokogiri'
# The 'pg' Ruby library, an interface to the PostgreSQL Relational Database Management System.
gem 'pg'
# A make-like build utility for Ruby. https://ruby.github.io/rake
gem 'rake'
# Classy web-development dressed in a DSL (official / canonical repo) http://www.sinatrarb.com/
gem 'sinatra'
# Extends Sinatra with ActiveRecord helper methods and Rake tasks.
gem 'sinatra-activerecord'
# Collection of common Sinatra extensions, semi-officially supported.
gem 'sinatra-contrib'

group :development, :test do
  # Debugging in Ruby 2
  gem 'byebug'
end

group :test do
  # A library for setting up Ruby objects as test data. https://thoughtbot.com/open-source
  gem 'factory_bot'
  # A library for generating fake data such as names, addresses, and phone numbers.
  gem 'faker', :git => 'https://github.com/faker-ruby/faker.git', :branch => 'master'
  # Create customizable MiniTest output formats.
  gem 'minitest-reporters'
  # Rack::Test is a layer on top of Rack's MockRequest similar to Merb's RequestHelper
  gem 'rack-test'
end