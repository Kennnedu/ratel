class RecordQuery
  attr_reader :relation

  def initialize(relation = Record.all)
    @relation = relation
  end

  def filter(params)
    if params['name'].present?
      include_name_list = params['name'].split('&').reject { |name| name[0].eql? '!' }.map { |name| "%#{name}%" }
      exclude_name_list = params['name'].split('&').select { |name| name[0].eql? '!' }.map { |name| "%#{name[1..-1]}%" }

      if include_name_list.present?
        @relation = @relation.where('records.name ILIKE ANY (array[?])', include_name_list)
      end

      if exclude_name_list.present?
        exclude_name_list.each { |name|  @relation = @relation.where.not('records.name ILIKE ?', name) }
      end
    end

    if params['card'].present?
      @relation = @relation.left_joins(:card)

      include_card_list = params['card'].split('&').reject { |card| card.eql? '!' }.map { |card| "%#{card}%" }
      exclude_card_list = params['card'].split('&').select { |card| card.eql? '!' }.map { |card| "%#{card[1..-1]}%" }

      if include_card_list.present?
        @relation = @relation.where('cards.name ILIKE ANY (array[?])', include_card_list)
      end

      if exclude_card_list.present?
        exclude_card_list.each { |card| @relation = @relation.where.not('cards.name ILIKE ?', card) }
      end
    end

    if params['tags'].present?
      @relation = @relation.left_joins(:tags)

      include_tag_list = params['tags'].split('&').reject { |tag| tag.eql? '!' }.map { |tag| "%#{tag}%" }
      exclude_tag_list = params['tags'].split('&').select { |tag| tag.eql? '!' }.map { |tag| "%#{tag[1..-1]}%" }

      if include_tag_list.present?
        @relation = @relation.where('tags.name ILIKE ANY (array[?])', include_tag_list)
      end

      if exclude_tag_list.present?
        exclude_tag_list.each { |tag| @relation = @relation.where.not('tags.name ILIKE ?', tag) }
      end
    end

    if params['performed_at'] && valid_date?(params['performed_at']['gt'])
      @relation = @relation.where('records.performed_at > ?', valid_date?(params['performed_at']['gt']))
    end

    if params['performed_at'] && valid_date?(params['performed_at']['lt'])
      @relation = @relation.where('records.performed_at < ?', valid_date?(params['performed_at']['lt']) + 1.day)
    end

    if params['amount'] && params['amount']['lt']
      @relation = @relation.where('records.amount < ?', params['amount']['lt'].to_i)
    end

    if params['amount'] && params['amount']['gt']
      @relation = @relation.where('records.amount > ?', params['amount']['gt'].to_i)
    end

    self
  end

  def order(params)
    if valid_ordering_condition?(params)
      @relation = @relation.order("#{params['order']['field'].downcase} #{params['order']['type'].downcase}")
    else
      @relation = @relation.order('performed_at DESC') 
    end

    self
  end

  def belongs_to_user(user_id)
    @relation = @relation.where(user_id: user_id) if user_id.present?
    self
  end

  def preload_ref
    @relation = @relation.includes(:card, records_tags: [:tag])
    self
  end

  def perform_recent
    @relation = @relation.order(performed_at: :desc)
    self
  end

  private

  def valid_date?(date_string)
    DateTime.parse(date_string)
  rescue
    nil
  end

  def valid_ordering_condition?(params)
    params['order'] && params['order']['type'] && params['order']['field'] &&
      %w(desc asc).include?(params['order']['type']) && Record.column_names.include?(params['order']['field'])
  end
end