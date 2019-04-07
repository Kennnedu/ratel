require 'nokogiri'

class StatementTableParser
  attr_accessor :table_file
  attr_reader :result

  def parse!
    @tr_nodes.shift
    record_json = {}

    @tr_nodes.each do |node|
       is_replaish = node.css('td')[5].content.gsub(/BYN|\s/, '').gsub(',', '.').to_f.eql? 0.0
      @result.push({
        'name' => is_replaish ? 'REPLENISHMENT' : node.css('td')[4].content.squish.gsub("\"", ''),
        'card' => node.css('td')[2].content,
        'amount' => node.css('td')[is_replaish ? 6 : 5].content.gsub(/BYN|\s/, '').gsub(',', '.').to_f,
        'rest' => is_replaish ? 0.0 : node.css('td')[7].content.gsub(/BYN|\s/, '').gsub(',', '.').to_f,
        'performed_at' => DateTime.parse(node.css('td')[0].content).to_s
      })
    end

    @result
  end

  def table_file=(table_file = nil)
    @table_file = table_file
    @tr_nodes = Nokogiri::HTML(@table_file).css('tr')
    @result = []
  end

  alias initialize table_file=
end
