# frozen_string_literal: true

require 'api/base_controller'

module Api
  class TagsController < BaseController
    include Import['queries.find_tags']

    get '/' do
      json tags: find_tags.call(scope: @current_user.tags, record_scope: @current_user.records, params: params).as_json
    end

    post '/' do
      crud_response(
        @current_user.tags.new(JSON.parse(request.body.read)['tag']).tap(&:save)
      )
    end

    put '/:id' do |id|
      crud_response(
        @current_user.tags.find_by(id: id)&.tap { |t| t.update(JSON.parse(request.body.read)['tag']) }
      )
    end

    delete '/:id' do |id|
      crud_response Tag.find_by(id: id, user_id: @current_user.id)&.destroy
    end
  end
end
