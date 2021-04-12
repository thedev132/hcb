module PayoutService
  module Donation
    class Create
      def initialize(donation_id:)
        @donation_id = donation_id
      end

      def run
        return nil unless donation.payout_id.nil?
        return nil unless donation.in_transit?
        return nil unless funds_available?

        ActiveRecord::Base.transaction do
          payout.save!
          fee_reimbursement.save!
          donation.update_column(:payout_id, payout.id)
          donation.update_column(:fee_reimbursement_id, fee_reimbursement.id)

          payout
        end
      end

      private

      def payout
        @payout ||= ::DonationPayout.new(donation: donation)
      end

      def fee_reimbursement
        @fee_reimbursement ||= FeeReimbursement.new(donation: donation)
      end

      def donation
        @donation ||= ::Donation.find(@donation_id)
      end

      def funds_available?
        Time.current.to_i > donation.remote_donation.charges.data.first.balance_transaction.available_on
      end
    end
  end
end
