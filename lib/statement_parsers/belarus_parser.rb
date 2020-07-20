# frozen_string_literal: true

require_relative 'statement_parser_base'
require_relative '../row_decorators/belarus_row_decorator'

class BelarusParser < StatementParserBase
  def parse!
    @row_decorator.card = card

    super
  end

  def row_decorator_instance
    BelarusRowDecorator.new nil
  end

  def rows
    @file.css('table[border="0"][cellspacing="0"][width="100%"][bgcolor="#BFDDDD"]').css('tr')
  end

  protected

  def card
    rows.select { |t| t.css('td').size.eql? 1 }[0].content.split('******')[1].first 6
  end
end
