# frozen_string_literal: true

module ReportIterator
  module ItemAdapters
    class HtmlBnbItemAdapter
      attr_accessor :item, :card

      def as_json
        { 'name' => name, 'card' => card, 'amount' => amount, 'performed_at' => performed_at }
      end

      protected

      def name
        info[0..bracket_start_index - 3]
      end

      def card
        info[bracket_start_index..-2]
      end

      def amount
        @item.css('td[colspan="2"]')[2].css('span').text.gsub(' BYN', '').to_f
      end

      def performed_at
        date = @item.css('td[colspan="2"]').css('span').first.text
        @last_peformed_at = DateTime.parse(date).to_s
      rescue StandardError
        @last_peformed_at ||= Time.now
      end

      private

      def info
        @item.css('td[colspan="2"]')[1].css('span').text
      end

      def bracket_start_index
        info.reverse.index('(') * -1
      end
    end
  end
end
