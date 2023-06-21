# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckService::Create, type: :model do
  context "when an event has ample balance" do
    it "creates a check with the correct amount" do
      # Set up event with ample balance of 1000 cents
      event = create(:event)
      canonical_transaction = create(:canonical_transaction, amount_cents: 1000)
      create(:canonical_event_mapping, event:, canonical_transaction:)

      lob_address = create(:lob_address, event:)

      service = described_class.new(
        event_id: event.id,
        lob_address_id: lob_address.id,
        payment_for: "",
        memo: "",
        amount_cents_string: "2.07", # this specific amount can indicate a rounding error, e.g. ("2.07".to_f * 100).to_i => 206
        send_date: Date.today + 2,
        current_user: create(:user)
      )

      expect do
        service.run
      end.to change(Check, :count).by(1)

      expect(Check.last.amount).to eq(207)
    end

  end
end
