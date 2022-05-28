# frozen_string_literal: true

module ReportIterator
  module Props
    class HtmlTableProps
      include Import['report_iterator.item_adapters.html_table_item_adapter']

      attr_accessor :report

      def collection
        @report.css('tr')[1..-1]
      end

      def item_adapter
        html_table_item_adapter
      end

      def compatible?(report)
        file = Nokogiri::HTML(report.document.read)
        !report.document.metadata['filename'].include?('.csv') && file.css('table').size == 1
      end

      def report=(report)
        @report = Nokogiri::HTML(report.document.read)
      end
    end
  end
end
