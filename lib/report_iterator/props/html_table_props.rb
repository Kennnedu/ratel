# frozen_string_literal: true

module Props
  class HtmlTableProps
    attr_reader :html_table_item_adapter
    attr_accessor :report

    def initialize
      @html_table_item_adapter = ItemAdapters::HtmlTableItemAdapter.new
    end

    def collection
      @report.css('tr')[1..-1]
    end

    def item_adapter
      html_table_item_adapter
    end
  end
end
