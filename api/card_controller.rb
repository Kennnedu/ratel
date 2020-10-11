require_relative './base_api_controller.rb'

class CardController < BaseApiController
  def initialize
    super
  end

  get '/' do
    json cards: FindCards.new(@current_user.cards).call(@current_user, params).as_json
  end

  post '/' do
    crud_response(
      CreateResource.new(@current_user.cards, JSON.parse(request.body.read)['card']).process
    )
  end

  put '/:id' do |id|
    crud_response(
      UpdateResource.new(
        Card.find_by(id: id, user_id: @current_user.id),
        JSON.parse(request.body.read)['card']
      ).process
    )
  end

  delete '/:id' do |id|
    crud_response Card.find_by(id: id, user_id: @current_user.id)&.destroy
  end
end
