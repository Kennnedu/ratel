# frozen_string_literal: true

Container.boot(:sidekiq) do |app|
  init do
    require 'sidekiq'
    require 'sidekiq/web'

    Sidekiq.configure_client do |config|
      config.redis = { url: ENV['REDIS_URL'], size: 1 }
    end

    Sidekiq.configure_server do |config|
      config.on(:startup) do
        ActiveRecord::Base.clear_active_connections!
      end
    end

    app.require_from_root('app/workers/*')
  end
end
