module Temp
  module SyncReceiptsToHcbCodes
    class Nightly
      def run
        # StripeAuthorizations
        Receipt.where(receiptable_type: "CanonicalTransaction").find_each(batch_size: 100) do |receipt|
          next unless receipt.receiptable

          hcb_code = HcbCode.where(hcb_code: receipt.receiptable.hcb_code).first
          next unless hcb_code
          next if hcb_code.receipts.present? # skip if already has a comment set

          create_receipt!(receipt: receipt, hcb_code: hcb_code)
        end
      end

      private

      def create_receipt!(receipt:, hcb_code:)
        attrs = {
          user_id: receipt.user_id,
          created_at: receipt.created_at,
          receiptable_type: 'HcbCode',
          receiptable_id: hcb_code.id,
          file: receipt.file.blob
        }
        Receipt.create!(attrs)
      end
    end
  end
end
