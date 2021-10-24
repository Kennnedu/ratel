# frozen_string_literal: true

require 'csv'

module ReportIterator
  module Props
    class CsvProps
      PARSE_OPTS = {
        headers: %w[date note amount_account_currency account_currency_code amount_transaction_currency
                    transaction_currency_code],
        col_sep: ';',
        encoding: 'windows-1251:utf-8',
        quote_char: '|'
      }.freeze

      include Import['report_iterator.item_adapters.csv_item_adapter']

      attr_accessor :report

      def collection
        initial_query[3..-1]
      end

      def item_adapter
        csv_item_adapter.card = card
        csv_item_adapter
      end

      protected

      def initial_query
        CSV.parse(report, PARSE_OPTS)
      end

      def card
        /(?<=Номер счета:)(.*)(?= Доступный остаток)/.match(initial_query[0]['date']).to_s
      end
    end
  end
end
