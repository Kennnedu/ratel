# frozen_string_literal: true

require_relative 'report_iterator_base'
require_relative '../item_decorators/html_table_item_decorator'

class HtmlTableIterator < ReportIteratorBase
  def item_decorator_instance
    HtmlTableItemDecorator.new nil
  end

  def collection
    @file.css('tr')[1..-1]
  end
end
