require_relative './base_api_controller.rb'

class CardsController < BaseApiController
  def initialize
    super
  end

  get '/' do
    json cards: FindCards.new(@current_user.cards).call(@current_user, params).as_json
  end

  post '/' do
    crud_response(
      @current_user.cards.new(JSON.parse(request.body.read)['card']).tap { |c| c.save }
    )
  end

  put '/:id' do |id|
    crud_response(
      @current_user.cards.find_by(id: id).tap { |c| c&.update(JSON.parse(request.body.read)['card']) }
    )
  end

  delete '/:id' do |id|
    crud_response Card.find_by(id: id, user_id: @current_user.id)&.destroy
  end
end
