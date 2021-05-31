# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::IndexContract, type: :model do
  let(:attrs) do
    {}
  end

  let(:contract) { Api::V1::IndexContract.new.call(attrs) }

  it "is successful" do
    expect(contract).to be_success
  end
end
