# frozen_string_literal: true

require_relative '../../apps/report_iterator/system/boot'

class CreateBulkRecord
  def initialize(current_user, file)
    @file = file
    @user = current_user
  end

  def process(rec_opt = {})
    ActiveRecord::Base.transaction do
      ReportIterator['iterator'].foreach(@file) do |record_attr|
        card = @user.cards.find_or_create_by(name: record_attr['card'])
        record_attr.delete :card
        @user.records.find_or_create_by(record_attr.merge(card: card).merge(rec_opt))
      end
    end
  end
end
