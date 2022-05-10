# frozen_string_literal: true

class ReceiptUploadsMailbox < ApplicationMailbox
  # mail --> Mail object, this actual email
  # inbound_email => ActionMailbox::InboundEmail record  --> the active storage record

  def process
    ensure_user
    ensure_hcb
    ensure_attachment
    # All good, now let's create the receipts
    result = ::ReceiptService::Create.new(receiptable: hcb,
                                          uploader: user,
                                          attachments: attachments,).run!

    if result
      # Success
      bounce_with ReceiptUploadMailer.notify_success(inbound_email, from: mail.from, to: mail.to)
    else
      # Error
      bounce_with ReceiptUploadMailer.notify_error(inbound_email, from: mail.from, to: mail.to)
    end
  end

  private

  def user
    @user ||= User.find_by(email: mail.from)
  end

  def hcb
    @email_comment ||= mail.to.first.match(/\+.*\@/i)[0]
    @hcb_code_hashid ||= @email_comment.match(/hcb-(.*)\@/i).captures.first
    @hcb ||= HcbCode.find_by_hashid(@hcb_code_hashid)
  end

  def attachments
    @attachments ||= mail.attachments.map do |atta|
      {
        io: StringIO.new(atta.decoded),
        content_type: atta.content_type,
        filename: atta.filename
      }
    end
  end

  def ensure_user
    # Send email back if user is not found in the db make sure to send us an email from an account that does exist
    bounce_with ReceiptUploadMailer.missing_user(mail.from, mail.to) if user.nil?
  end

  def ensure_hcb
    # Send email back if hcb code can't be matched
    bounce_with ReceiptUploadMailer.missing_hcb(mail.from, mail.to) if hcb.nil?
  end

  def ensure_attachment
    # Send email back if we don't detect any attachments
    bounce_with ReceiptUploadMailer.missing_attachments(mail.from, mail.to) unless attachments.any?
  end

end
