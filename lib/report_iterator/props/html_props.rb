# frozen_string_literal: true

module ReportIterator
  module Props
    class HtmlProps
      include Import['report_iterator.item_adapters.html_item_adapter']

      attr_accessor :report

      def collection
        initial_query.select { |t| t.css('td').size.eql? 7 }
      end

      def item_adapter
        html_item_adapter.card = card
        html_item_adapter
      end

      def compatible?(report)
        file = Nokogiri::HTML(report.document.read)
        !report.document.metadata['filename'].include?('.csv') && file.css('table').size > 1 && !file.text.include?('БНБ Банк')
      end

      def report=(report)
        @report = Nokogiri::HTML(report.document.read.force_encoding('windows-1251').encode('utf-8'))
      end

      protected

      def initial_query
        @report.css('table[border="0"][cellspacing="0"][width="100%"][bgcolor="#BFDDDD"]').css('tr')
      end

      def card
        initial_query.select { |t| t.css('td').size.eql? 1 }[0].content.split('******')[1][0..5]
      end
    end
  end
end
