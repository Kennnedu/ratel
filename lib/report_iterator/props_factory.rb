# frozen_string_literal: true

module ReportIterator
  class PropsFactory
    include Import['report_iterator.props.html_props', 'report_iterator.props.html_table_props',
                   'report_iterator.props.csv_props', 'report_iterator.props.html_bnb_props']

    def initialize(args)
      @props_list = args.values
    end

    def get_props(report)
      @props_list.each do |current_props|
        next unless current_props.compatible?(report)
        current_props.report = report
        return current_props
      end
    end
  end
end
