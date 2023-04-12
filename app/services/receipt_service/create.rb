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
        upload_method: @upload_method,
        receiptable: @receiptable   # Receiptable may be nil
      }
    end

  end
end
