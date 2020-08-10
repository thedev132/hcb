# frozen_string_literal: true

require "rails_helper"

RSpec.describe BankAccount, type: :model do
  fixtures "bank_accounts"

  let(:bank_account) { bank_accounts(:bank_account1) }

  it "is valid" do
    expect(bank_account).to be_valid
  end
end
