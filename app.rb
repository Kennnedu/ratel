require 'sinatra'
require "sinatra/activerecord"

require_relative 'lib/statement_table_parser.rb'
Dir["#{File.dirname(__FILE__)}/models/*.rb"].each {|file| require file }

get '/' do
  'Hello world!'
end
