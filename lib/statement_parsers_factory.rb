# frozen_string_literal: true

require_relative './statement_parsers/belinvest_parser'
require_relative './statement_parsers/belarus_parser'
require 'nokogiri'

class StatementParsersFactory
  def initialize(file)
    @file = Nokogiri::HTML(file)
  end

  def self.new_parser(file)
    new(file).new_parser
  end

  def new_parser
    parser_class = @file.text.include?('BELARUSBANK') ? BelarusParser : BelinvestParser
    parser_class.new @file
  end
end
