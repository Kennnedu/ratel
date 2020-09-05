# frozen_string_literal: true

require_relative 'report_iterator_base'
require_relative '../item_decorators/xml_item_decorator'

class XmlIterator < ReportIteratorBase
  def item_decorator_instance
    XmlItemDecorator.new nil
  end

  def collection
    @file.css('items').css('item')
  end
end
