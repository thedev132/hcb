# frozen_string_literal: true

module ReceiptService
  class Create
    def initialize(attachments:, uploader:, upload_method: nil, receiptable: nil)
      @attachments = attachments
      @receiptable = receiptable
      @uploader = uploader
      @upload_method = upload_method
    end

    def run!
      suppress(ActiveModel::MissingAttributeError) do
        @receiptable&.update(marked_no_or_lost_receipt_at: nil)
      end

      @attachments.map do |attachment|
        receipt = Receipt.create!(attrs(attachment))

        next if receipt.user.nil?

        pairings = ::ReceiptService::Suggest.new(receipt:).run!

        unless pairings.nil?
          pairs = pairings.map do |pairing|
            {
              receipt_id: receipt.id,
              hcb_code_id: pairing[:hcb_code].id,
              distance: pairing[:distance],
              aasm_state: "unreviewed"
            }
          end

          SuggestedPairing.insert_all(pairs) if pairs.any?
        end

        receipt
      end
    end

    private

    def attrs(attachment)
      {
        file: attachment,
        uploader: @uploader,
        upload_method: @upload_method,
        receiptable: @receiptable   # Receiptable may be nil
      }
    end

  end
end
