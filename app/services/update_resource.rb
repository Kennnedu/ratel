# frozen_string_literal: true

class UpdateResource
  def initialize(resource, params)
    @resource = resource
    @params = params
  end

  def process
    @resource&.update @params
    @resource
  end
end
