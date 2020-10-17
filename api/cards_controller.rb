# frozen_string_literal: true

require_relative './base_api_controller.rb'

class CardsController < BaseApiController
  attr_reader :find_cards

  def initialize
    super
    @find_cards = Container['queries.find_cards']
  end

  get '/' do
    json cards: find_cards.call(scope: @current_user.cards, record_scope: @current_user.records, params: params).as_json
  end

  post '/' do
    crud_response(
      @current_user.cards.new(JSON.parse(request.body.read)['card']).tap(&:save)
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
