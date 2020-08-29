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

  describe "#initials" do
    context "when missing name" do
      before do
        user.full_name = nil
        user.save!
      end

      it "returns initials from email" do
        expect(user.initials).to eql("UMC") # strange behavior. TODO: grab name out front of email and then initialize on that.
      end
    end
  end
end

