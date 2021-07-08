# frozen_string_literal: true

require 'api/base_controller'

module Api
  class RulesController < BaseController
    get '/' do
      json rules: paginate(
        @current_user.rules.order(created_at: :desc)
      ).as_json,
           offset: @offset,
           limit: @limit,
           total_count: @total
    end

    post '/' do
      crud_response(@current_user.rules.new(JSON.parse(request.body.read)).tap(&:save))
    end

    put '/:id' do |id|
      crud_response(
        @current_user.rules.find_by(id: id).tap { |c| c&.update(JSON.parse(request.body.read)) }
      )
    end

    delete '/:id' do |id|
      crud_response Rule.find_by(id: id, user_id: @current_user.id)&.destroy
    end
  end
end
