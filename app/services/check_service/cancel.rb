module CheckService
  class Cancel
    def initialize(check_id:)
      @check_id = check_id
    end

    def run
      check.mark_canceled!

      check
    end

    def check
      @check ||= Check.find(@check_id)
    end
  end
end
