# frozen_string_literal: true

Container.boot(:sidekiq) do |app|
  init do
    require 'sidekiq'

    app.require_from_root('app/workers/*')
  end
end
