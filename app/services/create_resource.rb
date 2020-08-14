# frozen_string_literal: true

class CreateResource
  def initialize(relation, params)
    @relation = relation
    @params = params
  end

  def process
    resource = @relation.new @params
    resource.save
    resource
  end
end
