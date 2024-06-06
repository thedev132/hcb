# frozen_string_literal: true

class User
  module PayoutMethod
    class PaypalTransfer < ApplicationRecord
      self.table_name = "user_payout_method_paypal_transfers"
      has_one :user, inverse_of: :payout_method, foreign_key: "payout_method_id"
      validates :recipient_email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
      validates_presence_of :recipient_email
      after_save_commit -> { Reimbursement::PayoutHolding.where(report: user.reimbursement_reports).failed.each(&:mark_settled!) }

      def kind
        "paypal_transfer"
      end

      def icon
        "paypal"
      end

      def name
        "a PayPal transfer"
      end

    end
  end

end
