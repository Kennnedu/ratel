# frozen_string_literal: true

Container.boot(:bugsnag) do
  init do
    require 'bugsnag'

    Bugsnag.configure do |config|
      config.api_key = ENV['BUGSNAG_KEY']
      config.notify_release_stages = ['production']
      config.project_root = Dir.pwd
    end
  end
end
