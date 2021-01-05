# frozen_string_literal: true

module ReportIterator
  module ItemAdapters
    class HtmlItemAdapter
      attr_accessor :item, :card

      def as_json
        result = { 'name' => name, 'amount' => amount, 'performed_at' => performed_at }
        result.merge!('card' => card) if card
        result
      end

      protected

      def name
        @item.css('td')[3].content
      end

      def amount
        amt = @item.css('td')[6].content.gsub(',', '.').to_f

        return amt if replenish?

        amt * -1
      end

      def performed_at
        @last_peformed_at = DateTime.parse(@item.css('td')[0].text.strip).to_s
      rescue StandardError
        @last_peformed_at ||= Time.now
      end

      private

      def replenish?
        @item.css('td')[6].content.include? '+'
      end
    end
  end
end
