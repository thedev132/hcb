# frozen_string_literal: true

class ApplicationMailbox < ActionMailbox::Base
  # routing /something/i => :somewhere

  # Routing all the incoming emails to the HcbCodeReceipts Mailbox
  # ie. "receipts+hcb-123abc@hcb.hackclub.com" for HcbCodes
  routing /^receipts\+/i => :hcb_code_receipts

  # ie. "animal.1234" for Users
  routing /#{MailboxAddress::VALIDATION_REGEX}/i => :receipt_bin

  # fallback
  routing all: :fallback

  # Helper methods
  private

  def html
    mail.html_part&.body&.decoded
  end

  def text
    mail.text_part&.body&.decoded
  end

end
