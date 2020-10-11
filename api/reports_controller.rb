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
    crud_response CreateResource.new(Report, params.merge(user_id: @current_user.id)).process
  end

  delete '/:id' do |id|
    crud_response Report.find_by(id: id, user_id: @current_user.id)&.destroy
  end
end
