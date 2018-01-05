require_relative "../exchange/coindesk_helper"

module MyCrypto
  class Portfolio
    @positions = []

    def self.from_positions(positions = [])
      p = Portfolio.new
      p.set_positions(positions)
      puts "Set Positions: #{ p.positions }"
      p.merge_positions(self.environment_positions) if !self.environment_positions.nil?
      p
    end

    def positions
      @positions
    end

    def set_positions(positions)
      @positions = positions
    end

    def currency_exposure
      #TODO: Replace with a reduce
      total_value = 0
      positions.each do |position|
        total_value += position[:usd].to_f
      end

      position_exposures = @positions.map do |position|
        puts "Position: " + position.to_s
        #TODO: Trim this to 3 dp properly
        portion = (position[:usd].to_f / total_value).round(4)
        {
          currency: position[:currency],
          exposure: portion,
          movement_30d: position[:movement_30d]
        }
      end

      #TODO: Improve logic to use a reduction
      # Clean data to ensure sum(each) = 100%
      total_exposure = 0
      position_exposures.map do |position_exposure|
        total_exposure += position_exposure[:exposure]
      end
      if total_exposure > 1.0
        #TODO: Make the data make sense!!
      end

      position_exposures.sort! do |a,b|
        case
        when a[:exposure] < b[:exposure]
          1
        when a[:exposure] > b[:exposure]
          -1
        else
          0
        end
      end
      #TODO: Sort this list
      position_exposures
    end


    # Managing Environment Positions
    def self.environment_positions
      @environment_positions ||= ENV.map do |var|
        if !var.nil? && var[0].start_with?("MYCRYPTO_BALANCE")
          
          currency = var[0].sub("MYCRYPTO_BALANCE_", "")
          amount = var[1].to_f
          
          market = Exchange::Base.exchange.market_summary(market:"BTC-#{currency}")
          price = 1
          if market || currency == "BTC"
            price = market["Last"] if currency != "BTC"
            puts "Adding position: #{amount} #{ currency } @ #{ price }"
            {
              currency: currency,
              amount: amount,
              price: price,
              usd: amount * price * Exchange::CoindeskHelper.bitcoin_to_usd,
              movement_30d: 0
            }
          else
            puts "Skipping position as couldn't find market for #{ currency }"
            nil
          end
        end
      end.compact!
      @environment_positions
    end

    def merge_positions(new_positions)
      return if new_positions.nil?

      new_positions.each do |new_position|
        puts "Merging in new position"
        item_list = @positions.find_all {|position| position[:currency] === new_position[:currency]}
        if item_list.length > 0
          item = item_list[0]
          item[:amount] = item[:amount] + new_position[:amount].to_f
          item[:usd] = item[:amount] * item[:price] * Exchange::CoindeskHelper.bitcoin_to_usd
          puts "Merge Positions: Added to #{ new_position[:currency] } position. New balance: #{ item[:amount] } "
        else
          puts "Merge Positions: Adding new position #{ new_position[:amount] } #{ new_position[:currency] }"
          @positions << new_position
        end
      end
    end
  end
end
