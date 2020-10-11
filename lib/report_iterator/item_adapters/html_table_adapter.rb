# frozen_string_literal: true

module ItemAdapters
  class HtmlTableItemAdapter
    attr_accessor :item

    def as_json
      { 'name' => name, 'card' => card, 'amount' => amount, 'performed_at' => performed_at, 'rest' => rest }
    end

    protected

    def name
      replenish? ? 'REPLENISHMENT' : @item.css('td')[6].content.squish.gsub('"', '')
    end

    def card
      @item.css('td')[2].content
    end

    def amount
      @item.css('td')[8].content.gsub(' ', '').gsub(',', '.').to_f
    end

    def rest
      replenish? ? 0.0 : @item.css('td')[9].content.gsub(/BYN|\s/, '').gsub(',', '.').to_f
    end

    def performed_at
      DateTime.parse(@item.css('td')[0].content).to_s
    end

    private

    def replenish?
      @item.css('td')[7].content.gsub(/BYN|\s/, '').gsub(',', '.').to_f.eql? 0.0
    end
  end
end