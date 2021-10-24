# frozen_string_literal: true

module ReportIterator
  class PropsFactory
    include Import['report_iterator.props.html_props', 'report_iterator.props.html_table_props',
                   'report_iterator.props.csv_props']

    def get_props(report)
      props = if report.document.metadata['filename'].include?('.csv')
                file = report.document.read.force_encoding('windows-1251').encode('utf-8')
                csv_props
              else
                file = Nokogiri::HTML(report.document.read)
                file.css('table').size > 1 ? html_props : html_table_props
              end

      props.report = file
      props
    end
  end
end
