# frozen_string_literal: true

module BankFeeService
  class Weekly
    def run
      bank_fees = []

      Event.pending_fees_v2.each do |event|
        bank_fees << BankFeeService::Create.new(event_id: event.id).run
      end

      return if bank_fees.empty?

      FeeRevenue.create!(
        bank_fees: bank_fees,
        amount_cents: bank_fees.sum { |fee| fee.amount_cents.abs },
        start: Date.today.last_week, # The previous Monday
        end: Date.yesterday
      )

      true
    end

  end
end
