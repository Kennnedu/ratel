# frozen_string_literal: true

Container.boot(:sidekiq) do |app|
  init do
    require 'sidekiq'
    require 'sidekiq/web'

    Sidekiq.configure_client do |config|
      config.redis = { size: 1 }
    end

    app.require_from_root('app/workers/*')
  end
end
