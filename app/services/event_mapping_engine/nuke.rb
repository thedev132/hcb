module EventMappingEngine
  class Nuke
    def run
      CanonicalEventMapping.delete_all
    end
  end
end
