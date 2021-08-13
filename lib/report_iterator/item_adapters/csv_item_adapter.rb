# frozen_string_literal: true

module ReportIterator
  module ItemAdapters
    class CsvItemAdapter
      attr_accessor :item, :card

      def as_json
        { 'name' => name, 'amount' => amount, 'performed_at' => performed_at }.tap do |item_hash|
          item_hash['card'] = card if card
        end
      end

      protected

      def name
        @item['note'].gsub(/\s+/, ' ').strip
      end

      def amount
        @item['amount_account_currency'].to_f
      end

      def performed_at
        DateTime.parse(@item['date']).to_s
      rescue StandardError
        Time.now
      end
    end
  end
end
