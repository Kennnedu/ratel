class TableRowParser
  attr_reader :name, :card, :reset, :performed_at

  def initialize(node_row)
    @node_row = node_row
  end

  def self.parse!(node_row, prev_res)
    new(node_row).parse!(prev_res)
  end

  def parse!(prev_res)
    parse_is_corrency
    parse_is_replanish
    raise unless defined?(@is_replanish) || defined?(@is_currency)

    parse_name
    parse_card
    parse_rest
    parse_performed_at
    parse_amount prev_res
  end

  def as_json(options = {})
    super({except: ['node_row', 'is_replanish', 'is_currency']}.merge options)
  end

  def parse_name
    @name = @is_replanish ? 'REPLENISHMENT' : @node_row.css('td')[4].content.squish.gsub("\"", '')
  end

  def parse_card
    @card = @node_row.css('td')[2].content
  end

  def parse_amount(prev_res)
    @amount = if @is_currency && prev_res && @rest
                binding.pry
                (prev_res['rest'].to_d - @rest.to_d).to_f
              else
                @node_row.css('td')[@is_replanish ? 6 : 5].content.gsub(/BYN|\s/, '').gsub(',', '.').to_f
              end
  end

  def parse_rest
    @rest = @is_replanish ? 0.0 : @node_row.css('td')[7].content.gsub(/BYN|\s/, '').gsub(',', '.').to_f
  end

  def parse_performed_at
    @performed_at = DateTime.parse(@node_row.css('td')[0].content).to_s
  end

  def parse_is_replanish
    @is_replanish = @node_row.css('td')[5].content.gsub(/BYN|\s/, '').gsub(',', '.').to_f.eql? 0.0
  end

  def parse_is_corrency
    @is_currency = !@is_replanish && !@node_row.css('td')[5].content.include?('BYN')
  end
end
