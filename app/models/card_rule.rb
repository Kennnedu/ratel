# frozen_string_literal: true

class CardRule < Rule
  belongs_to :card

  validate :only_user_cards

  def action(record)
    record.update(card: card)
  end

  def only_user_cards
    errors.add(:card_id, 'isn\'t found') unless user.cards.pluck(:id).include?(card_id)
  end
end
