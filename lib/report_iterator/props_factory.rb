# frozen_string_literal: true

class PropsFactory
  include Import['report_iterator.props.html_props', 'report_iterator.props.html_table_props']

  def get_props(file)
    props = file.css('table').size > 1 ? html_props : html_table_props
    props.report = file
    props
  end
end
