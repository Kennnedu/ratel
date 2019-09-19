require_relative './statement_parsers/belinvest_parser'
require_relative './statement_parsers/belarus_parser'
require 'nokogiri'

class StatementParsersFactory
  def initialize(file)
    @file = Nokogiri::HTML(file)
  end

  def self.get_parser(file)
    new(file).get_parser
  end

  def get_parser
    parser_class = @file.text.include?('BELARUSBANK') ? BelarusParser : BelinvestParser
    parser_class.new @file
  end
end
