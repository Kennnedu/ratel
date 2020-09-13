# frozen_string_literal: true

class FindRecords < BaseQuery
  KEYWORD_SEPARATOR = '&'
  KEYWORD_EXCLUDE = '!'

  def call(params)
    filter_by_ids params
    filter_by_name params['name']
    filter_by_card params['card']
    filter_by_tag params['tags']
    filter_by_ammount params['amount']
    filter_by_performed_at params['performed_at']
    uniq params
    order params
    @relation
  end

  protected

  def default_relation
    Record.all
  end

  def default_order
    @relation.recent
  end

  def filter_by_ids(params)
    @relation = @relation.where(id: params['ids']) if params['ids']&.is_a?(Array)

    @relation = @relation.where.not(id: params['except_ids']) if params['except_ids']&.is_a?(Array)
  end

  def filter_by_name(params_name)
    return unless params_name

    only_names, except_names = get_lists_from params_name
    @relation = @relation.only_keywords('records.name', only_names) if only_names.presence
    @relation = @relation.except_keywords('records.name', except_names) if except_names.presence
  end

  def filter_by_card(params_card)
    return unless params_card

    only_cards, except_cards = get_lists_from(params_card)
    @relation = @relation.left_joins(:card) if only_cards.presence || except_cards.presence
    @relation = @relation.only_keywords('cards.name', only_cards) if only_cards.presence
    return unless except_cards.presence

    @relation = @relation.except_keywords('cards.name', except_cards).or(@relation.where('cards.name is null'))
  end

  def filter_by_tag(params_tag)
    return unless params_tag

    only_tags, except_tags = get_lists_from(params_tag)
    @relation = @relation.left_joins(:tags) if only_tags.presence || except_tags.presence
    @relation = @relation.only_keywords('tags.name', only_tags) if only_tags.presence
    return unless except_tags.presence

    @relation = @relation.except_keywords('tags.name', except_tags).or(@relation.where('tags.name is null'))
  end

  def filter_by_ammount(params_ammount)
    return unless params_ammount

    greater_amount = params_ammount['gt']&.to_f
    less_amount =  params_ammount['lt']&.to_f

    @relation = @relation.greater_amount(greater_amount) if greater_amount
    @relation = @relation.less_amount(less_amount) if less_amount
  end

  def filter_by_performed_at(params_performed_at)
    return unless params_performed_at

    greater_performed = parse_date(params_performed_at['gt'])
    less_performed = parse_date(params_performed_at['lt'])

    @relation = @relation.greater_performed_at(greater_performed) if greater_performed
    @relation = @relation.less_performed_at(less_performed + 1.day) if less_performed
  end

  def uniq(params)
    @relation = @relation.distinct if params['card'] || params['tags']
  end

  private

  def get_lists_from(field)
    field.to_s.split(KEYWORD_SEPARATOR).partition { |k| !k.first.eql? KEYWORD_EXCLUDE }.map do |l|
      l.map { |k| k.presence ? "%#{k.gsub(KEYWORD_EXCLUDE, '')}%" : next }.compact
    end
  end
end
