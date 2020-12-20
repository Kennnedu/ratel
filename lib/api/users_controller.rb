# frozen_string_literal: true

require 'api/base_controller'

module Api
  class UsersController < BaseController
    get('/') { crud_response @current_user }

    put('/') { crud_response @current_user.tap { |u| u.update params['user'] } }
  end
end
