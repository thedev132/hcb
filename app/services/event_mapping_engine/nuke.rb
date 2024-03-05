# frozen_string_literal: true

module EventMappingEngine
  class Nuke
    def run
      Fee.delete_all
      CanonicalEventMapping.delete_all
    end

  end
end
