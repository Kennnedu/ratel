# frozen_string_literal: true

require 'import'

class PropsFactory
  include Import[
    html_report_props: 'props.html_props',
    html_table_report_props: 'props.html_table_props'
  ]

  def get_props(file)
    props = file.text.include?('BELARUSBANK') ? html_report_props : html_table_report_props
    props.report = file
    props
  end
end
