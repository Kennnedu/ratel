# frozen_string_literal: true

module ReportIterator
  class PropsFactory
    include Import['report_iterator.props.html_props', 'report_iterator.props.html_table_props',
                   'report_iterator.props.csv_props']

    def get_props(file)
      props = if File.extname(file).eql?('.csv')
                csv_props
              else
                file = Nokogiri::HTML(file)
                file.css('table').size > 1 ? html_props : html_table_props
              end

      props.report = file
      props
    end
  end
end
