module MyCrypto
  class Portfolio
    @positions = []

    def self.from_positions(positions = [])
      p = Portfolio.new
      if !positions.nil?
        p.set_positions(positions)
      end
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
        #TODO: Trim this to 3 dp properly
        portion = (position[:usd].to_f / total_value).round(3)
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
  end
end
