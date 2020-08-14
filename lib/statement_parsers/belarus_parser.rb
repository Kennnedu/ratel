# frozen_string_literal: true

require_relative 'statement_parser_base'
require_relative '../row_decorators/belarus_row_decorator'

class BelarusParser < StatementParserBase
  def row_decorator_instance
    instance = BelarusRowDecorator.new nil
    instance.card = card
    instance
  end

  def rows
    initial_query_rows.select { |t| t.css('td').size.eql? 7 }
  end

  protected

  def initial_query_rows
    @file.css('table[border="0"][cellspacing="0"][width="100%"][bgcolor="#BFDDDD"]').css('tr')
  end

  def card
    initial_query_rows.select { |t| t.css('td').size.eql? 1 }[0].content.split('******')[1].first 6
  end
end
