module Temp
  class CreateHistoricBankFees
    def initialize(event_id:)
      @event_id = event_id
    end

    def run
      event.canonical_transactions.likely_hack_club_fee.each do |ct|
        next if ct.bank_fee.present? || ct.hcb_code.starts_with?("HCB-700-")

        ActiveRecord::Base.transaction do
          # 1. create bank fee
          bank_fee = event.bank_fees.create!(attrs(ct))

          # 2. update ct
          ct.update_column(:hcb_code, bank_fee.hcb_code)
        end
      end

      nil
    end

    private

    def attrs(ct)
      {
        aasm_state: "settled",
        amount_cents: ct.amount_cents,
        created_at: ct.date - 2.days
      }
    end

    def event
      @event ||= Event.find(@event_id)
    end
  end
end
