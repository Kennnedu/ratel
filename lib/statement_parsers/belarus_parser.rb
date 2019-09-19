require_relative 'statement_parser_base'
require_relative '../row_decorators/belarus_row_decorator'

class BelarusParser < StatementParserBase
  def initialize(file)
    super
    @row_decorator = BelarusRowDecorator.new nil
  end

  def parse!
    rows = @file.css('table[border="0"][cellspacing="0"][width="100%"][bgcolor="#BFDDDD"]').css('tr')
    @row_decorator.card = rows.select { |t| t.css('td').size.eql? 1 }[0]
                              .content.split("******")[1].first 6
    super rows.select {|t| t.css('td').size.eql? 7 }
  end
end
