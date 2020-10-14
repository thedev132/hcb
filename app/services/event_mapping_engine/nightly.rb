module EventMappingEngine
  class Nightly
    def initialize
    end

    def run
      ::EventMappingEngine::Map::Historical.new.run
      ::EventMappingEngine::Map::Github.new.run
    end
  end
end