# frozen_string_literal: true

require 'import'

module Props
  class HtmlProps
    include Import[
      html_item_adapter: 'item_adapters.html_item_adapter'
    ]

    attr_accessor :report

    def collection
      initial_query.select { |t| t.css('td').size.eql? 7 }
    end

    def item_adapter
      html_item_adapter.card = card
      html_item_adapter
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
