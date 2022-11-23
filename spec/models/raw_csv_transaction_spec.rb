# frozen_string_literal: true

require "rails_helper"

RSpec.describe RawCsvTransaction, type: :model do
  it "is valid" do
    raw_csv_transaction = create(:raw_csv_transaction)
    expect(raw_csv_transaction).to be_valid
  end
end
