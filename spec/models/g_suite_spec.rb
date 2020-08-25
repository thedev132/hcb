# frozen_string_literal: true

require "rails_helper"

RSpec.describe GSuite, type: :model do
  fixtures "g_suites"

  let(:g_suite) { g_suites(:g_suite1) }

  it "is valid" do
    expect(g_suite).to be_valid
  end

  describe "#domain" do
    context "when domain is nil" do
      it "is not valid" do
        g_suite.domain = nil

        expect(g_suite).to_not be_valid
      end
    end

    context "when domain is missing extension" do
      it "is not valid" do
        g_suite.domain = "example"

        expect(g_suite).to_not be_valid
      end
    end
  end

  describe "#verification_url" do
    it "generates it" do
      result = g_suite.verification_url

      expect(result).to eql("https://www.google.com/webmasters/verification/verification?siteUrl=http://event1.example.com")
    end
  end

  describe "#ou_name" do
    let(:event) { g_suite.event }

    it "generates it" do
      expect(g_suite.ou_name).to eql("##{event.id} #{event.name}")
    end

    context "when event name has a + in it" do
      before do
        event.name = "Tech+Me"
        event.save!
      end

      it "removes the +" do
        expect(g_suite.ou_name).to eql("##{event.id} TechMe")
      end
    end
  end

  describe "#aasm_state" do
    it "defaults to configuring" do
      expect(g_suite).to be_configuring
    end

    context "when attempting to mark verifying" do
      it "transitions" do
        expect do
          g_suite.mark_verifying!
        end.to change(g_suite, :verifying?).to(true)
      end

      context "when attempting to mark verified" do
        before do
          g_suite.mark_verifying!
        end

        it "transitions" do
          expect do
            g_suite.mark_verified!
          end.to change(g_suite, :verified?).to(true)
        end

        context "when attempting to go back to configuring" do
          it "fails transition" do
            expect do
              g_suite.mark_verifying!
            end.to raise_error(AASM::InvalidTransition)
          end
        end
      end
    end
  end
end

