# frozen_string_literal: true

require_relative './report_iterators/html_table_iterator.rb'
require_relative './report_iterators/html_iterator.rb'
require 'nokogiri'

class ReportIteratorFactory
  def initialize(file)
    @file = Nokogiri::HTML(file)
  end

  def self.new_iterator(file)
    new(file).new_iterator
  end

  def new_iterator
    iterator_class = @file.text.include?('BELARUSBANK') ? HtmlIterator : HtmlTableIterator
    iterator_class.new @file
  end
end
