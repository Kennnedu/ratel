# frozen_string_literal: true

require 'api/base_controller'

module Api
  class ReportsController < BaseController
    get '/' do
      json reports: paginate(
        @current_user.reports.order(created_at: :desc)
      ).as_json,
           offset: @offset,
           limit: @limit,
           total_count: @total
    end

    post '/' do
      crud_response(@current_user.reports.new(params).tap(&:save))
    end

    delete '/:id' do |id|
      crud_response Report.find_by(id: id, user_id: @current_user.id)&.destroy
    end
  end
end
