class StatementParserBase
  attr_accessor :file
  attr_reader :result

  def initialize(file)
    @file = file
    @result = []
    @row_decorator = nil
  end

  def parse!(rows)
    @result = rows.map do |row|
      @row_decorator.__setobj__(row)
      @row_decorator.as_json
    end
  end
end
