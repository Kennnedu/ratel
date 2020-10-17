# frozen_string_literal: true

class ReportIterator
  attr_reader :props_factory

  def initialize
    @props_factory = PropsFactory.new
  end

  def foreach(file)
    report_props = props_factory.get_props(Nokogiri::HTML(file))
    item_adapter = report_props.item_adapter

    report_props.collection.each do |item|
      item_adapter.item = item
      yield item_adapter.as_json
    end
  end
end
