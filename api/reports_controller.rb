require_relative './base_api_controller.rb'

class ReportsController < BaseApiController
  def initialize
    super
  end
  
  get '/' do
    json reports: paginate(
      Report.all.order(created_at: :desc)
    ).as_json,
         offset: @offset,
         limit: @limit,
         total_count: @total
  end

  post '/' do
    crud_response(@current_user.reports.new(params).tap { |r| r.save })
  end

  delete '/:id' do |id|
    crud_response Report.find_by(id: id, user_id: @current_user.id)&.destroy
  end
end
