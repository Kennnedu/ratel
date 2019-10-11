require 'sinatra/base'

class AppController < Sinatra::Application
  get '/' do
    erb :application
  end
end