require_relative './base_api_controller.rb'

class RecordController < BaseApiController
  def initialize
    super
  end 
  
  get '/' do
    json records: paginate(
      FindRecords.new(@current_user.records.includes(:card, records_tags: [:tag])).call(params)
    ).as_json,
         offset: @offset,
         limit: @limit,
         total_count: @total
  end

  get '/sum' do
    json sum: Record.from(
      FindRecords.new(@current_user.records).call(params).distinct.select(:id, :amount).reorder(:amount),
      'names'
    ).sum('names.amount')
  end

  get '/names' do
    json record_names: paginate(
      FindRecordNames.new(
        FindRecords.new(@current_user.records).call(params['record'] || {}).select('records.name').group('records.name')
          .unscope(:order)
      ).call(params)
    ).as_json(except: :id, include: {}),
         offset: @offset,
         limit: @limit,
         total_count: @total
  end

  post '/' do
    crud_response(
      CreateResource.new(Record, JSON.parse(request.body.read)['record'].merge(user_id: @current_user.id)).process
    )
  end

  post '/bulk' do
    CreateBulkRecord.new(@current_user, params['html_file']['tempfile'].read).process
    halt 200
  end

  put '/' do
    UpdateBulkRecord.new(
      FindRecords.new(@current_user.records).call(params),
      params['batch_form'],
      params['removing_tag_ids']
    ).process

    halt 200
  end

  put '/:id' do |id|
    crud_response(
      UpdateResource.new(
        Record.find_by(id: id, user: @current_user),
        JSON.parse(request.body.read)['record']
      ).process
    )
  end

  delete '/' do
    FindRecords.new(@current_user.records).call(params).destroy_all
    halt 200
  end

  delete '/:id' do |id|
    crud_response Record.find_by(id: id)&.destroy
  end
end

