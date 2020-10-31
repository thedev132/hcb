module EventMappingEngine
  class Nightly
    def initialize
    end

    def run
      map_historical!
      map_github!

      true
    end

    private

    def map_historical!
      ::EventMappingEngine::Map::Historical.new.run
    end

    def map_github!
      ::EventMappingEngine::Map::Github.new.run
    end
  end
end
