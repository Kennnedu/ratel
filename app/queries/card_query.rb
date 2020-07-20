# frozen_string_literal: true

class CardQuery
  FIELD_MAP = {
    'created_at' => 'cards.created_at',
    'updated_at' => 'cards.updated_at',
    'records_sum' => 'coalesce(sum(records.amount), 0) as records_sum'
  }.freeze

  attr_reader :relation

  def initialize(relation = Card.all)
    @relation = relation
  end

  def filter(user_id, params)
    params_fields = params['fields'].to_s.split(',')

    fields = ['cards.id', 'cards.name'] + params_fields.map { |f| FIELD_MAP[f] }.compact

    @relation = @relation.select fields.join(', ')

    if params_fields.include?('records_sum')
      records_query = RecordQuery.new.belongs_to_user(user_id).filter(params['record'] || {}).relation

      @relation = @relation.joins("left join (#{records_query.to_sql}) records on cards.id = records.card_id")
                           .group('cards.id')

      if params['records_sum'] && params['records_sum']['lt']
        @relation = @relation.having('coalesce(sum(records.amount), 0) < ?', params['records_sum']['lte'].to_i)
      end

      if params['records_sum'] && params['records_sum']['gt']
        @relation = @relation.having('coalesce(sum(records.amount), 0) > ?', params['records_sum']['gte'].to_i)
      end
    end

    self
  end

  def order(params)
    @relation = if valid_ordering_condition?(params)
                  @relation.order("#{params['order']['field'].downcase} #{params['order']['type'].downcase}")
                else
                  @relation.order('created_at DESC')
                end

    self
  end

  def belongs_to_user(user_id)
    @relation = @relation.where(user_id: user_id) if user_id.present?
    self
  end

  private

  def valid_ordering_condition?(params)
    params['order'] && params['order']['type'] && params['order']['field'] &&
      %w[desc asc].include?(params['order']['type']) &&
      (Card.column_names.include?(params['order']['field']) ||
       (params['order']['field'].eql?('records_sum') && params['fields'].include?('records_sum')))
  end
end
