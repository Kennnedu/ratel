# frozen_string_literal: true

class CreateBulkRecord
  def initialize(current_user, file)
    @parser = StatementParsersFactory.new_parser file
    @user = current_user
  end

  def process
    @parser.parse!

    ActiveRecord::Base.transaction do
      @parser.result.each do |record|
        card = @user.cards.find_or_create_by(name: record['card'])
        record.delete :card
        @user.records.find_or_create_by(record.merge(card: card))
      end
    end
  end
end
