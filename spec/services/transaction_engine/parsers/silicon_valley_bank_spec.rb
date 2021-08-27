# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransactionEngine::Parsers::SiliconValleyBank do
  let(:filepath) { file_fixture("silicon_valley_bank1.csv") }

  let(:attrs) do
    {
      filepath: filepath
    }
  end

  let(:service) { TransactionEngine::Parsers::SiliconValleyBank.new(attrs) }

  it "runs" do
    expect do
      service.run
    end.to change(RawCsvTransaction, :count).by(2)
  end

  it "is idempotent" do
    service.run

    expect do
      service.run
    end.to_not change(RawCsvTransaction, :count)
  end
end
