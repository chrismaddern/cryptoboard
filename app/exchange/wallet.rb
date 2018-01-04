module MyCrypto
  module Exchange
    class Wallet
      attr_accessor :currency
      attr_accessor :balance
      attr_accessor :available
      attr_accessor :pending
      attr_accessor :address
      attr_accessor :exchange

      def estimated_bitcoin_value_per_unit
        summary = exchange.market_summary(market: "BTC-#{currency}")
        return summary["Last"] if summary
        return 0
      end

      # for the whole wallet
      def estimated_bitcoin_value
        return balance if currency == "BTC"
        estimated_bitcoin_value_per_unit * balance
      end

      # for the whole wallet
      def estimated_dollar_value
        estimated_bitcoin_value * Exchange::CoindeskHelper.bitcoin_to_usd
      end

    end
  end
end
