# frozen_string_literal: true

Container.boot(:logger) do
  init do
    require 'logger'
  end

  start do
    register(:logger, Logger.new($stdout))
  end
end
