# frozen_string_literal: true

require_relative 'statement_parser_base'
require_relative '../row_decorators/belinvest_row_decorator'

class BelinvestParser < StatementParserBase
  def row_decorator_instance
    BelinvestRowDecorator.new nil
  end

  def rows
    @file.css('tr')[1..-1]
  end
end
