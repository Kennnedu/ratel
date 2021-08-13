# frozen_string_literal: true

module ReportIterator
  class ReportIterator
    include Import['report_iterator.props_factory']

    def foreach(file)
      report_props = props_factory.get_props(file)
      item_adapter = report_props.item_adapter

      report_props.collection.each do |item|
        item_adapter.item = item
        yield item_adapter.as_json
      end
    end
  end
end
