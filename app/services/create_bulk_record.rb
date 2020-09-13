# frozen_string_literal: true

class CreateBulkRecord
  def initialize(current_user, file)
    @iterator = ReportIteratorFactory.new_iterator file
    @user = current_user
  end

  def process(rec_opt = {})
    ActiveRecord::Base.transaction do
      @iterator.foreach do |record_attr|
        card = @user.cards.find_or_create_by(name: record_attr['card'])
        record_attr.delete :card
        @user.records.find_or_create_by(record_attr.merge(card: card).merge(rec_opt))
      end
    end
  end
end
