# frozen_string_literal: true

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
  end
end
