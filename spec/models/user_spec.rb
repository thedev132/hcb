# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  fixtures "users"

  let(:user) { users(:user1) }

  it "is valid" do
    expect(user).to be_valid
  end

  it "is admin" do
    expect(user).to be_admin
  end
end

