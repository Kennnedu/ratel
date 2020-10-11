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
      @current_user.tags.new(JSON.parse(request.body.read)['tag']).tap { |t| t.save }
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
