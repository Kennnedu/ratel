require_relative './base_api_controller.rb'

class TagsController < BaseApiController
  def initialize
    super
  end 

  get '/' do
    json tags: FindTags.new(@current_user.tags).call(@current_user, params).as_json
  end

  post '/' do
    crud_response(
      CreateResource.new(Tag, JSON.parse(request.body.read)['tag'].merge(user_id: @current_user.id)).process
    )
  end

  put '/:id' do |id|
    crud_response(
      UpdateResource.new(Tag.find_by(id: id, user_id: @current_user.id), JSON.parse(request.body.read)['tag']).process
    )
  end

  delete '/:id' do |id|
    crud_response Tag.find_by(id: id, user_id: @current_user.id)&.destroy
  end
end
