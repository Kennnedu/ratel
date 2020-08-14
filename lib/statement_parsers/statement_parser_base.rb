# frozen_string_literal: true

class StatementParserBase
  attr_accessor :file
  attr_reader :result

  def initialize(file)
    @file = file
    @result = []
  end

  def parse!
    @row_decorator = row_decorator_instance

    @result = rows.map do |row|
      @row_decorator.__setobj__(row)
      @row_decorator.as_json
    end
  end

  def row_decorator_instance
    raise NotImplementedError
  end

  def rows
    raise NotImplementedError
  end
end
