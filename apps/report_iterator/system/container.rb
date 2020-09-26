# frozen_string_literal: true

require 'dry/system/container'

class ReportIterator < Dry::System::Container
  configure do |config|
    config.name = :report_iterator
    config.auto_register = %w[lib]
  end

  load_paths!('lib', 'system')
end
