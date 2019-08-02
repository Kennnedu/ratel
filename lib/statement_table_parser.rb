require 'nokogiri'
require_relative 'table_row_parser.rb'

class StatementTableParser
  attr_reader :result

  def initialize(html_table = nil)
    @html_table = html_table
    @tr_nodes = Nokogiri::HTML(@html_table).css('tr')
    @result = []
  end

  def parse!
    @tr_nodes.shift
    binding.pry
    map_tr_nodes(@tr_nodes.reverse) { |node, prev_res| TableRowParser.parse!(node, prev_res).as_json }
  rescue
    nil
  end

  def map_tr_nodes(tr_nodes)
    i = 0

    while i < tr_nodes.length
      @result << yield(tr_nodes[i], @result.last)
      i += 1
    end

    @result
  end
end
