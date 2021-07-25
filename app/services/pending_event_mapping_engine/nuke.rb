# frozen_string_literal: true

module PendingEventMappingEngine
  class Nuke
    def run
      CanonicalPendingEventMapping.delete_all
    end
  end
end
