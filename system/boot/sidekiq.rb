# frozen_string_literal: true

Container.boot(:sidekiq) do
  init do
    require 'sidekiq'

    Dir[File.dirname(__FILE__) + '/../../app/workers/*.rb'].each { |file| require file }
  end
end
