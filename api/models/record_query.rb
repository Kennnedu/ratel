class RecordQuery
  attr_reader :relation

  def initialize(relation = Record.all)
    @relation = relation
  end

  def filter(params)
    @relation = @relation.left_joins(:card)

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
      include_card_list = params['card'].split('&').reject { |card| card.eql? '!' }.map { |card| "%#{card}%" }
      exclude_card_list = params['card'].split('&').select { |card| card.eql? '!' }.map { |card| "%#{card[1..-1]}%" }

      if include_card_list.present?
        @relation = @relation.where('cards.name ILIKE ANY (array[?])', include_card_list)
      end

      if exclude_card_list.present?
        exclude_card_list.each { |card| @relation = @relation.where.not('cards.name ILIKE ?', card) }
      end
    end

    if date_from = valid_date?(params['from'])
      @relation = @relation.where('records.performed_at > ?', date_from + 1.day)
    end

    if date_to = valid_date?(params['to'])
      @relation = @relation.where('records.performed_at < ?', date_to + 1.day)
    end

    self
  end

  def dashboard_table_data(table)
    case table
    when 'cards'
      cards_data
    when 'replenishments'
      replenishments_data
    when 'expenses'
      expenses_data
    when 'tags'
      tags_data
    else
      self
    end
  end

  def tags_data
    @relation = @relation.joins(:tags).group('tags.name').order('sum_amount DESC').sum(:amount)
    self
  end

  def replenishments_data
    @relation = @relation.where('records.amount > ?', 0).group(:name).order('sum_amount DESC').sum(:amount)
    self
  end

  def expenses_data
    @relation = @relation.where('records.amount < ?', 0).group(:name).order('sum_amount ASC').sum(:amount)
    self
  end

  def cards_data
    @relation = @relation.group('cards.name').order('sum_amount DESC').sum(:amount)
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
    Date.parse(date_string)
  rescue
    nil
  end
end