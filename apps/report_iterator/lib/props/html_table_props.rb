# frozen_string_literal: true

require 'import'

module Props
  class HtmlTableProps
    include Import[
      html_table_item_adapter: 'item_adapters.html_table_item_adapter'
    ]

    attr_accessor :report

    def collection
      @report.css('tr')[1..-1]
    end

    def item_adapter
      html_table_item_adapter
    end
  end
end
