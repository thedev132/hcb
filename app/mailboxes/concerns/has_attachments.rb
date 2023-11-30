# frozen_string_literal: true

module HasAttachments
  extend ActiveSupport::Concern

  included do
    private

    def set_attachments
      files = mail.attachments.map do |atta|
        {
          io: StringIO.new(atta.decoded),
          content_type: atta.content_type,
          filename: atta.filename
        }
      end

      return @attachments = files if files.any?

      if (content = html || text)
        @attachments = [{
          io: StringIO.new(WickedPdf.new.pdf_from_string(content)),
          content_type: "application/pdf",
          filename: "Email_#{(mail.subject || Time.now.strftime("%Y%m%d%H%M")).gsub(/[^0-9A-Za-z]/, '').slice(0, 30)}.pdf"
        }]
      end
    end

    def bounce_missing_attachments
      bounce_with HcbCodeReceiptsMailer.with(mail: inbound_email, reply_to: mail.to.first).bounce_missing_attachment
    end

  end

end
