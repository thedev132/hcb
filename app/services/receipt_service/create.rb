# frozen_string_literal: true

module ReceiptService
  class Create
    def initialize(receiptable:, attachments:, uploader:)
      @attachments = attachments
      @receiptable = receiptable
      @uploader = uploader
    end

    def run!
      receipt_ids = []
      ActiveRecord::Base.transaction do
        @attachments.each do |attachment|
          receipt_ids << Receipt.create!(attrs(attachment))
        end
      end
      Receipt.where(id: receipt_ids)
    end

    private

    def attrs(attachment)
      {
        file: attachment,
        uploader: @uploader,
        receiptable_type: @receiptable.class.name,
        receiptable_id: @receiptable.id
      }
    end

  end
end
