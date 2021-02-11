module CheckService
  class Cancel
    def initialize(check_id:)
      @check_id = check_id
    end

    def run
      ActiveRecord::Base.transaction do
        check.mark_canceled!

        # ::Partners::Lob::Checks::Cancel.new(id: check.lob_id).run # not supported/necessary on our plan
      end
    end

    def check
      @check ||= Check.find(@check_id)
    end
  end
end
