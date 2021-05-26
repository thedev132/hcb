# frozen_string_literal: true

module TransactionGroupingEngine
  module Calculate
    class HcbCode
      # PATTERN: HCB-TRANSACTION/TYPE/SOURCE-UNIQUEIDENTIFIER
      #
      HCB_CODE = "HCB"
      SEPARATOR = "-"
      UNKNOWN_CODE = "000"
      INVOICE_CODE = "100"
      DONATION_CODE = "200"
      PARTNER_DONATION_CODE = "201"
      ACH_TRANSFER_CODE = "300"
      CHECK_CODE = "400"
      DISBURSEMENT_CODE = "500"
      STRIPE_CARD_CODE = "600"
      BANK_FEE_CODE = "700"

      def initialize(canonical_transaction_or_canonical_pending_transaction:)
        @ct_or_cp = canonical_transaction_or_canonical_pending_transaction
      end

      def run
        return invoice_hcb_code if invoice
        return bank_fee_hcb_code if bank_fee
        return donation_hcb_code if donation
        return ach_transfer_hcb_code if ach_transfer
        return check_hcb_code if check
        return disbursement_hcb_code if disbursement
        return stripe_card_hcb_code if raw_stripe_transaction
        return stripe_card_hcb_code_pending if raw_pending_stripe_transaction

        unknown_hcb_code
      end

      private

      def invoice_hcb_code
        [
          HCB_CODE,
          INVOICE_CODE,
          invoice.id
        ].join(SEPARATOR)
      end

      def invoice
        @invoice ||= @ct_or_cp.invoice
      end

      def bank_fee_hcb_code
        [
          HCB_CODE,
          BANK_FEE_CODE,
          bank_fee.id
        ].join(SEPARATOR)
      end

      def bank_fee
        @bank_fee ||= @ct_or_cp.bank_fee
      end

      def donation_hcb_code
        [
          HCB_CODE,
          DONATION_CODE,
          donation.id
        ].join(SEPARATOR)
      end

      def donation
        @donation ||= @ct_or_cp.donation
      end

      def ach_transfer_hcb_code
        [
          HCB_CODE,
          ACH_TRANSFER_CODE,
          ach_transfer.id
        ].join(SEPARATOR)
      end

      def ach_transfer
        @ach_transfer ||= @ct_or_cp.ach_transfer
      end

      def check_hcb_code
        [
          HCB_CODE,
          CHECK_CODE,
          check.id
        ].join(SEPARATOR)
      end

      def check
        @check ||= @ct_or_cp.check
      end

      def disbursement_hcb_code
        [
          HCB_CODE,
          DISBURSEMENT_CODE,
          disbursement.id
        ].join(SEPARATOR)
      end

      def disbursement
        @disbursement ||= @ct_or_cp.disbursement
      end

      def stripe_card_hcb_code
        return unknown_hcb_code unless @ct_or_cp.remote_stripe_iauth_id.present?

        [
          HCB_CODE,
          STRIPE_CARD_CODE,
          @ct_or_cp.remote_stripe_iauth_id
        ].join(SEPARATOR)
      end

      def raw_stripe_transaction
        @raw_stripe_transaction ||= @ct_or_cp.raw_stripe_transaction
      end

      def stripe_card_hcb_code_pending
        raise ArgumentError, "stripe_card_hcb_code requires remote stripe iauth id" unless @ct_or_cp.remote_stripe_iauth_id.present?

        [
          HCB_CODE,
          STRIPE_CARD_CODE,
          @ct_or_cp.remote_stripe_iauth_id
        ].join(SEPARATOR)
      end

      def raw_pending_stripe_transaction
        @raw_pending_stripe_transaction ||= @ct_or_cp.raw_pending_stripe_transaction
      end

      def unknown_hcb_code
        [
          HCB_CODE,
          UNKNOWN_CODE,
          @ct_or_cp.id
        ].join(SEPARATOR)
      end
    end
  end
end
