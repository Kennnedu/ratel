# frozen_string_literal: true

class PropsFactory
  attr_reader :html_report_props, :html_table_report_props

  def initialize
    @html_report_props = Props::HtmlProps.new
    @html_table_report_props = Props::HtmlTableProps.new
  end

  def get_props(file)
    props = file.css('table').size > 1 ? html_report_props : html_table_report_props
    props.report = file
    props
  end
end
