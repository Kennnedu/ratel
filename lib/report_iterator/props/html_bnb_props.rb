# frozen_string_literal: true

module ReportIterator
  module Props
    class HtmlBnbProps
      include Import['report_iterator.item_adapters.html_bnb_item_adapter']

      attr_accessor :report

      def collection
        initial_query.reject { |row| row.to_html.include?('style="height:1px">') }
      end

      def item_adapter
        html_bnb_item_adapter
      end

      def compatible?(report)
        file = Nokogiri::HTML(report.document.read)
        !report.document.metadata['filename'].include?('.csv') && file.text.include?('БНБ Банк')
      end

      def report=(report)
        @report = Nokogiri::HTML(report.document.read)
      end

      protected

      def initial_query
        @report.css('table').css('table').css('tbody').css('tr')[12..-4]
      end
    end
  end
end
