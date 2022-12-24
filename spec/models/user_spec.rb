# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid" do
    user = create(:user)

    expect(user).to be_valid
  end

  it "is admin" do
    user = create(:user, admin_at: Time.now)

    expect(user).to be_admin
  end

  describe "#initials" do
    context "when missing name" do
      it "returns initials from email" do
        user = create(:user, email: "user1@example.com", full_name: nil)

        expect(user.initials).to eql("U")
      end
    end
  end

  describe "#safe_name" do
    context "when initial name is really long" do
      it "returns safe_name max of 24 chars" do
        user = create(:user, full_name: "Thisisareallyreallylongfirstnamethatembursewillnotlike Last")

        expect(user.safe_name).to eql("Thisisareallyreallylo L")
        expect(user.safe_name.length).to eql(23)
      end
    end
  end

  describe "#first_name" do
    context "when name is downcased" do
      it "returns" do
        user = create(:user, full_name: "ann marie")

        expect(user.first_name).to eql("ann")
      end
    end

    context "when multiple first names" do
      it "returns actual first name" do
        user = create(:user, full_name: "Prof. Donald Ervin Knuth")

        expect(user.first_name).to eql("Donald")
      end
    end

    context "when name entered with comma" do
      it "returns actual first name" do
        user = create(:user, full_name: "Turing, Alan M.")

        expect(user.first_name).to eql("Alan")
      end
    end
  end

  describe "#last_name" do
    it "returns actual last name" do
      user = create(:user, full_name: "Ken Griffey Jr.")

      expect(user.last_name).to eql("Griffey")
    end

    context "when name is downcased" do
      it "returns" do
        user = create(:user, full_name: "ann marie")

        expect(user.last_name).to eql("marie")
      end
    end

    context "when entered with comma" do
      it "returns actual last name" do
        user = create(:user, full_name: "Carreño Quiñones, María-Jose")

        expect(user.last_name).to eql("Quiñones")
      end
    end
  end

  describe "#initial_name" do
    it "returns" do
      user = create(:user, full_name: "First Last")

      expect(user.initial_name).to eql("First L")
    end

    context "when first name is missing" do
      it "returns" do
        user = create(:user, full_name: "Last")

        expect(user.initial_name).to eql("Last")
      end
    end

    context "when last name is missing" do
      it "returns" do
        user = create(:user, full_name: "First")

        expect(user.initial_name).to eql("First")
      end
    end

    context "when full_name is nil" do
      it "returns" do
        user = create(:user, email: "user1@example.com", full_name: nil)

        expect(user.initial_name).to eql("user1")
      end
    end
  end

  describe "#locked?" do
    context "when locked" do
      it "returns" do
        user = create(:user, locked_at: Time.now)
        expect(user).to be_locked
      end
    end

    context "when unlocked" do
      it "returns" do
        user = create(:user, locked_at: nil)
        expect(user).not_to be_locked
      end
    end
  end

  describe "#lock!" do
    it "locks" do
      user = create(:user, locked_at: nil)
      user.lock!
      expect(user).to be_locked
    end
  end

  describe "#unlock!" do
    it "unlocks" do
      user = create(:user, locked_at: Time.now)
      user.unlock!
      expect(user).not_to be_locked
    end
  end

  describe "#private" do
    describe "#namae" do
      context "when brackets in name" do
        it "can parse the name" do
          user = create(:user, full_name: "Zach Latta [Dev]")
          result = user.send(:namae)

          expect(result).to_not eql(nil)
          expect(result.given).to eql("Zach Latta")
          expect(result.family).to eql("Dev")
        end
      end

      context "when parentheses" do
        it "can parse the name" do
          user = create(:user, full_name: "Max (test) Wofford")
          result = user.send(:namae)

          expect(result).to_not eql(nil)
          expect(result.given).to eql("Max")
          expect(result.family).to eql("Wofford")
        end
      end

      context "when emojis in name" do
        it "can parse the name" do
          user = create(:user, full_name: "Melody ✨")
          result = user.send(:namae)

          expect(result).to_not eql(nil)
          expect(result.given).to eql("Melody")
          expect(result.family).to eql(nil)
        end
      end

      context "when a number" do
        it "can parse the name" do
          user = create(:user, full_name: "5512700050241863")
          result = user.send(:namae)

          expect(result).to_not eql(nil)
          expect(result.given).to eql("5512700050241863")
          expect(result.family).to eql(nil)
        end
      end
    end
  end

  describe "#api_access_token" do
    context "duplicate api tokens are created" do
      it "fails because of unique index violation" do
        token = "token"
        _existing_user = create(:user, api_access_token: token)

        expect do
          create(:user, api_access_token: token)
        end.to raise_error(ActiveRecord::RecordNotUnique, /index_users_on_api_access_token_bidx\b/)
      end
    end
  end

end
