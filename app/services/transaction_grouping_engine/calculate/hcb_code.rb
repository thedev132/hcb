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

      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        return invoice_hcb_code if invoice

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
