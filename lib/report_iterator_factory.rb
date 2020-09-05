# frozen_string_literal: true

require_relative './report_iterators/html_table_iterator.rb'
require_relative './report_iterators/html_iterator.rb'
require_relative './report_iterators/xml_iterator.rb'
require 'nokogiri'

class ReportIteratorFactory
  MIN_HTML_TABLES = 1.freeze

  def initialize(file)
    @file = file
  end

  def self.new_iterator(file)
    new(file).new_iterator
  end

  def new_iterator
    case File.extname @file
    when '.html', 'htm'
      html = Nokogiri::HTML(@file)
      (html.css('table').size.eql?(MIN_HTML_TABLES) ? HtmlTableIterator : HtmlIterator).new html
    when '.xml'
      XmlIterator.new Nokogiri::XML(@file)
    end
  end
end
