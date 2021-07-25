# frozen_string_literal: true

module CheckService
  class MarkInTransitAndProcessed
    def initialize(check_id:)
      @check_id = check_id
    end

    def run
      check.mark_in_transit_and_processed!

      check
    end

    def check
      @check ||= Check.find(@check_id)
    end
  end
end
