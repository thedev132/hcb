# frozen_string_literal: true

module CheckService
  class Send
    def initialize(check_id:)
      @check_id = check_id
    end

    def run
      raise ArgumentError, "Check must be in a scheduled state only." unless check.scheduled?

      ActiveRecord::Base.transaction do
        check.mark_in_transit!
        lob_check = Partners::Lob::Checks::Create.new(lob_attrs).run
        check.update_columns(update_attrs(lob_check: lob_check))
      end

      check.reload
    end

    private

    def lob_attrs
      {
        to: lob_address.lob_id,
        memo: check.memo,
        amount_cents: check.amount,
        description: check.description,
        message: message
      }
    end

    def update_attrs(lob_check:)
      transaction_memo = "#{lob_check["check_number"]} Check"[0..30]

      {
        lob_id: lob_check["id"],
        lob_url: lob_check["url"],
        check_number: lob_check["check_number"],
        transaction_memo: transaction_memo,
        expected_delivery_date: lob_check["expected_delivery_date"]
      }
    end

    def check
      @check ||= Check.find(@check_id)
    end

    def lob_address
      @lob_address ||= check.lob_address
    end

    def message
      "This check was sent by The Hack Foundation on behalf of #{event.name}. #{event.name} is fiscally sponsored by The Hack Foundation (d.b.a Hack Club), a 501(c)(3) nonprofit with the EIN 81-2908499. For any inquiries, please email bank@hackclub.com, which our financial operations team monitors daily on weekdays."
    end

    def description
      @description ||= "#{event.name} - #{lob_address.name}"[0..255]
    end

    def event
      @event ||= check.event
    end
  end
end
