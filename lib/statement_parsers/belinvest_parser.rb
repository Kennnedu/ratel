require_relative 'statement_parser_base'
require_relative '../row_decorators/belinvest_row_decorator'

class BelinvestParser < StatementParserBase
  def initialize(file)
    super(file)
    @row_decorator = BelinvestRowDecorator.new nil
  end

  def parse!
    rows = @file.css('tr')
    rows.shift

    super rows
  end
end
