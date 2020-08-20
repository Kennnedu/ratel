# frozen_string_literal: true

require_relative 'report_iterator_base'
require_relative '../item_decorators/html_item_decorator'

class HtmlIterator < ReportIteratorBase
  def item_decorator_instance
    instance = HtmlItemDecorator.new nil
    instance.card = card
    instance
  end

  def collection
    initial_query_collection.select { |t| t.css('td').size.eql? 7 }
  end

  protected

  def initial_query_collection
    @file.css('table[border="0"][cellspacing="0"][width="100%"][bgcolor="#BFDDDD"]').css('tr')
  end

  def card
    initial_query_collection.select { |t| t.css('td').size.eql? 1 }[0].content.split('******')[1].first 6
  end
end
