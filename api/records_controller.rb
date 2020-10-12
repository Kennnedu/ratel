require_relative './base_api_controller.rb'

class RecordsController < BaseApiController
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
      @current_user.records.new(JSON.parse(request.body.read)['record']).tap { |r| r.save }
    )
  end

  post '/bulk' do
    CreateBulkRecord.new.process(@current_user, params['html_file']['tempfile'].read)
    halt 200
  end

  put '/' do
    result = UpdateBulkRecord.new.process(@current_user, params)
    return halt(200) unless  result
    halt 400, { 'Content-Type' => 'application/json' }, { message: result }.to_json
  end

  put '/:id' do |id|
    crud_response(
      @current_user.records.find_by(id: id)&.tap { |r| r.update(JSON.parse(request.body.read)['record']) }
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

