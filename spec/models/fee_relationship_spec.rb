# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeeRelationship, type: :model do
  fixtures "fee_relationships", "transactions"

  let(:fee_relationship) { fee_relationships(:fee_relationship1) }

  it "is valid" do
    expect(fee_relationship).to be_valid
  end

  describe "fee_amount" do
    before do
      fee_relationship.update_column(:fee_amount, nil) # hacky because of the design of this model and schema. validations that are calculating values should move to a service in the future
    end

    it "defaults to nil" do
      expect(fee_relationship.fee_amount).to eql(nil)
    end

    context "when before_validation is called" do
      it "sets value to transaction.amount" do
        expect(fee_relationship).to receive(:calculate_fee).and_call_original

        fee_relationship.save # calls calculate_fee

        expect(fee_relationship.fee_amount).to eql(10010)
      end
    end

    context "when fee_applies is false" do
      before do
        fee_relationship.update_column(:fee_applies, false)
      end

      it "sets to nil" do
        expect(fee_relationship).to receive(:calculate_fee).and_call_original

        fee_relationship.save # calls calculate_fee

        expect(fee_relationship.fee_amount).to eql(nil)
      end
    end

    context "when fee amount already exists on the fee relationship" do
      let(:fee_amount) { 200 }

      before do
        fee_relationship.update_column(:fee_amount, fee_amount)
      end

      it "uses the fee_amount on the relationship rather than the transaction" do
        expect(fee_relationship.fee_amount).to eql(fee_amount)
      end
    end

    context "when fee payment is true" do
      let(:fee_relationship) { fee_relationships(:fee_relationship2) }

      before do
        fee_relationship.update_column(:fee_amount, nil)
      end

      context "when before_validation is called" do
        it "sets to nil since fee applies is false for fee payment trues" do
          expect(fee_relationship).to receive(:calculate_fee).and_call_original

          fee_relationship.save # calls calculate_fee

          expect(fee_relationship.fee_amount).to eql(nil)
        end
      end
    end
  end
end
