require "faraday"
require "json"

module MyCrypto
  module Exchange
    class CoindeskHelper
      def self.bitcoin_to_usd
        @_content ||= JSON.parse(Faraday.get("https://api.coindesk.com/v1/bpi/currentprice.json").body)

        return @_content["bpi"]["USD"]["rate_float"]
      end
    end
  end
end
