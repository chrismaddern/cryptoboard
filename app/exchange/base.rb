module MyCrypto
  module Exchange
    class Base
      def name
        nil
      end

      # The default method used by MyCrypto
      # Uses all_positions to build a Portfolio
      def portfolio
        nil
      end

      def all_positions
        []
      end

      def self.exchange
        @_exchange ||= MyCrypto::Exchange::Bittrex.new
      end
    end
  end
end
