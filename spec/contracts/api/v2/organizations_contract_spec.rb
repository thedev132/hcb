# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::OrganizationsContract, type: :model do
  let(:attrs) do
    {}
  end

  let(:contract) { Api::V2::OrganizationsContract.new.call(attrs) }

  it "is successful" do
    expect(contract).to be_success
  end
end
