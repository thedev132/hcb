# frozen_string_literal: true

require "rails_helper"

RSpec.describe RawEmburseTransaction, type: :model do
  it "is valid" do
    raw_emburse_transaction = create(:raw_emburse_transaction)
    expect(raw_emburse_transaction).to be_valid
  end
end
