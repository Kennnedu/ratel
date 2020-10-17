# frozen_string_literal: true

require 'dry/system/container'
require 'dry/system/components'

class Container < Dry::System::Container
  use :env, inferrer: -> { ENV.fetch('APP_ENV', :development).to_sym }

  load_paths! 'lib'

  configure do |config|
    config.name = :ratel_app
    config.default_namespace = 'ratel_app'
    config.auto_register = %w[lib]
  end
end
