module EventMappingEngine
  class Nightly
    def initialize
    end

    def run
      map_historical_plaid!
      map_historical_emburse!
      map_github!

      true
    end

    private

    def map_historical_plaid!
      ::EventMappingEngine::Map::HistoricalPlaid.new.run
    end

    def map_historical_emburse!
      ::EventMappingEngine::Map::HistoricalEmburse.new.run
    end

    def map_github!
      ::EventMappingEngine::Map::Github.new.run
    end
  end
end
