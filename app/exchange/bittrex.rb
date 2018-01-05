# Thanks to Felix Krause & the Brot project for
# this handy Bittrex code!

require "faraday"
require "digest"
require "openssl"
require "json"

require_relative "base"
require_relative "../portfolio/portfolio"
require_relative "wallet"
require_relative "coindesk_helper"

if ENV["MYCRYPTO_DEBUG"]
  puts "Enabling Charles proxy"
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  ENV["http_proxy"] = "https://127.0.0.1:8888"
end

module MyCrypto
  module Exchange
    class Bittrex < Exchange::Base
      def name
        "Bittrex"
      end

      def portfolio
        MyCrypto::Portfolio.from_positions(all_positions)
      end

      def all_positions
        if ENV["MYCRYPTO_FAKE_DATA"]
          fake_positions_response
        else
          positions = []
          wallets.each do |wallet|
            #TODO: Add real movement_30d
            position = {
              currency: wallet.currency,
              amount: wallet.available + wallet.pending,
              price: wallet.estimated_bitcoin_value_per_unit,
              usd: wallet.estimated_dollar_value,
              movement_30d: 0
            }
            positions << position
          end
          positions
        end
      end

      HOST = "https://bittrex.com/api/v1.1"

      def wallets
        @_wallets ||= request(url: "/account/getbalances").map do |current_wallet|
          wallet = MyCrypto::Exchange::Wallet.new
          wallet.exchange = self
          wallet.currency = current_wallet["Currency"]
          wallet.balance = current_wallet["Balance"]
          wallet.available = current_wallet["Available"]
          wallet.pending = current_wallet["Pending"]
          wallet.address = current_wallet["CryptoAddress"]

          wallet
        end

        return @_wallets
      end

      # Cached market_summaries
      def market_summaries
        @_market_summaries ||= request(url: "/public/getmarketsummaries")
      end

      def market_summary(market: nil)
        # we could use a different API too if we want to
        return market_summaries.find do |m|
          m["MarketName"] == market
        end
      end

      def market_details
        @market_details ||= request(url: "/public/getmarkets")
      end

      def market_detail(market: nil, from: nil, to: nil)
        market ||= market_name(from: from, to: to)
        # we could use a different API too if we want to
        return market_details.find do |m|
          m["MarketName"] == market
        end
      end

      # Network Requests
      def client
        @client ||= Faraday.new(url: HOST) do |c|
          c.adapter Faraday.default_adapter
          c.proxy "https://127.0.0.1:8888" if ENV["MYCRYPTO_DEBUG"]
        end
      end

      def request(url: nil, parameters: {})
        raise "Missing env variables `BITTREX_API_KEY`" if ENV["BITTREX_API_KEY"].to_s.length == 0
        raise "Missing env variables `BITTREX_SECRET`" if ENV["BITTREX_SECRET"].to_s.length == 0

        nonce = "0af9shfajq3rjafpoejfhoa8h39w4fhwifh"

        raw_params = parameters.dup
        parameters[:apikey] = ENV["BITTREX_API_KEY"]
        parameters[:nonce] = nonce
        parameters = parameters.to_a.sort

        full_url = File.join(HOST, url) + "?" + URI.encode_www_form(parameters)
        api_sign = OpenSSL::HMAC.hexdigest("SHA512", ENV["BITTREX_SECRET"], full_url)

        response = client.get do |req|
          req.url full_url
          req.headers["apisign"] = api_sign
        end

        parsed = JSON.parse(response.body)
        if parsed["success"] != true
          raise "Something went wrong: #{response.body} when trying to send #{raw_params} to #{url}"
        end
        return parsed["result"]
      end

      # Fake Data
      def fake_positions_response
        [
          {
            currency: "BTC",
            amount: 0.123,
            price: 1,
            usd: 1856.22,
            movement_30d: 0.32
          },
          {
            currency: "XRP",
            amount: 400,
            price: 0.001,
            usd: 1560.00,
            movement_30d: 1.28
          },
          {
            currency: "ETH",
            amount: 4,
            price: 0.1,
            usd: 3640.00,
            movement_30d: 0.29
          },
          {
            currency: "FUN",
            amount: 2000,
            price: 0.0003,
            usd: 160.00,
            movement_30d: 2.38
          },
          {
            currency: "XVG",
            amount: 120,
            price: 0.0004,
            usd: 351.60,
            movement_30d: 0
          },
          {
            currency: "MNR",
            amount: 2000,
            price: 0.02,
            usd: 2560,
            movement_30d:-0.21
          },
        ]
      end
    end
  end
end
