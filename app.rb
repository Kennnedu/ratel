require 'sinatra'
require "sinatra/activerecord"

Dir["#{File.dirname(__FILE__)}/models/*.rb"].each {|file| require file }

get '/' do
  'Hello world!'
end
