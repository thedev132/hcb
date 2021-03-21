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
      ACH_TRANSFER_CODE = "300"
      CHECK_CODE = "400"
      DISBURSEMENT_CODE = "500"
      STRIPE_CARD_CODE = "600"

      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        return invoice_hcb_code if invoice
        return donation_hcb_code if donation
        return ach_transfer_hcb_code if ach_transfer
        return check_hcb_code if check
        return disbursement_hcb_code if disbursement
        return stripe_card_hcb_code if raw_stripe_transaction

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
        @invoice ||= @canonical_transaction.invoice
      end

      def donation_hcb_code
        [
          HCB_CODE,
          DONATION_CODE,
          donation.id
        ].join(SEPARATOR)
      end

      def donation
        @donation ||= @canonical_transaction.donation
      end

      def ach_transfer_hcb_code
        [
          HCB_CODE,
          ACH_TRANSFER_CODE,
          ach_transfer.id
        ].join(SEPARATOR)
      end

      def ach_transfer
        @ach_transfer ||= @canonical_transaction.ach_transfer
      end

      def check_hcb_code
        [
          HCB_CODE,
          CHECK_CODE,
          check.id
        ].join(SEPARATOR)
      end

      def check
        @check ||= @canonical_transaction.check
      end

      def disbursement_hcb_code
        [
          HCB_CODE,
          DISBURSEMENT_CODE,
          disbursement.id
        ].join(SEPARATOR)
      end

      def disbursement
        @disbursement ||= @canonical_transaction.disbursement
      end

      def stripe_card_hcb_code
        [
          HCB_CODE,
          STRIPE_CARD_CODE,
          @canonical_transaction.id
        ].join(SEPARATOR)
      end

      def raw_stripe_transaction
        @raw_stripe_transaction ||= @canonical_transaction.raw_stripe_transaction
      end

      def unknown_hcb_code
        [
          HCB_CODE,
          UNKNOWN_CODE,
          @canonical_transaction.id
        ].join(SEPARATOR)
      end
    end
  end
end
