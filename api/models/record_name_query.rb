class RecordNameQuery
	FIELD_MAP = { 
		'created_name_at' => 'min(records.created_at) as created_name_at',
		'records_sum' => 'sum(records.amount) records_sum'
  }.freeze

	attr_reader :relation

  def initialize(relation = Record.select(:name).group(:name))
    @relation = relation
	end
	
	def filter(params)
		params_fields = params['fields'].to_s.split(',')

		fields = params_fields.map { |f| FIELD_MAP[f] }.compact

		if fields.presence
			@relation = @relation.select fields.join(', ')
		end

		if params['name']
			@relation = @relation.where('name ILIKE ?', "%#{params['name']}%")
		end

		if  params['records_sum'] && params['records_sum']['lt']
			@relation = @relation.having('coalesce(sum(records.amount), 0) < ?', params['records_sum']['lt'].to_i)
		end

		if  params['records_sum'] && params['records_sum']['gt']
			@relation = @relation.having('coalesce(sum(records.amount), 0) > ?', params['records_sum']['gt'].to_i)
		end

		if  params['created_name_at'] && valid_date?(params['created_name_at']['lt'])
			@relation = @relation.having('min(records.created_at) < ?', valid_date?(params['created_name_at']['lt']))
		end

		if  params['created_name_at'] && valid_date?(params['created_name_at']['gt'])
			@relation = @relation.having('min(records.created_at) > ?', valid_date?(params['created_name_at']['gt']))
		end

		self
	end

	def order(params)
		if valid_ordering_condition?(params)
      @relation = @relation.order("#{params['order']['field'].downcase} #{params['order']['type'].downcase}")
    else
      @relation = @relation.order('name ASC') 
		end

		self
	end

	def belongs_to_user(user_id)
		@relation = @relation.where(user_id: user_id)
		self
	end

	private

	def valid_ordering_condition?(params)
		params['order'] && params['order']['type'] && params['order']['field'] &&
      %w(desc asc).include?(params['order']['type']) && 
      (%w(created_name_at records_sum name).include?(params['order']['field']) || 
      (params['order']['field'].eql?('records_sum') && params['fields'].include?('records_sum')))
  end
  
  def valid_date?(date_string)
    DateTime.parse(date_string)
  rescue
    nil
  end
end