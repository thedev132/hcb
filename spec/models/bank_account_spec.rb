# frozen_string_literal: true

require "rails_helper"

RSpec.describe BankAccount, type: :model do
  let(:bank_account) { create(:bank_account) }

  it "is valid" do
    expect(bank_account).to be_valid
  end
end
