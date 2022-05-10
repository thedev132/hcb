# frozen_string_literal: true

class ApplicationMailbox < ActionMailbox::Base
  # routing /something/i => :somewhere

  # Routing all the incoming emails to the ReceiptUpload Mailbox
  # ie. "receipts+hcb-123abc@bank.hackclub.com"
  routing /^receipts\+/i => :receipt_uploads

end
