# frozen_string_literal: true

require 'sinatra/base'

class Statics < Sinatra::Base
  get '/uploads/*.*' do |name, ext|
    settings.default_encoding = 'ASCII-8BIT'
    Container.root.join('public', 'uploads', "#{name}.#{ext}").open
  end
end
