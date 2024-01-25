# frozen_string_literal: true

class HcbCodeReceiptsMailbox < ApplicationMailbox
  # mail --> Mail object, this actual email
  # inbound_email => ActionMailbox::InboundEmail record --> the active storage record

  include Pundit::Authorization
  include HasAttachments

  before_processing :set_attachments
  before_processing :set_hcb_code
  before_processing :set_user

  def process
    return bounce_missing_attachments unless @attachments
    return bounce_missing_hcb unless @hcb_code
    return bounce_missing_user unless @user
    return unless ensure_permissions?

    # All good, now let's create the receipts

    result = ::ReceiptService::Create.new(
      receiptable: @hcb_code,
      uploader: @user,
      attachments: @attachments,
      upload_method: "email_hcb_code"
    ).run!

    return bounce_error if result.empty?

    content = text || body || html

    email_command = content.match(/(?:^|\s)(?<tag>@rename)\s+(?<content>.+)/i)
    custom_memo = email_command&.[]("content")&.strip

    if custom_memo
      @hcb_code.canonical_transactions.each { |ct| ct.update!(custom_memo:) }
      @hcb_code.canonical_pending_transactions.each { |cpt| cpt.update!(custom_memo:) }
    end

    HcbCodeReceiptsMailer.with(
      mail: inbound_email,
      reply_to: @hcb_code.receipt_upload_email,
      renamed_to: custom_memo,
      receipts_count: result.size
    ).bounce_success.deliver_now
  end

  private

  def set_hcb_code
    email_comment = mail.to.first.match(/\+.*@/i)[0]
    hcb_code_hashid = email_comment.match(/hcb-(.*)@/i).captures.first
    @hcb_code = HcbCode.find_by_hashid hcb_code_hashid
  end

  def set_user
    @user = User.find_by(email: mail.from[0].downcase)
  end

  def bounce_missing_user
    bounce_with HcbCodeReceiptsMailer.with(mail: inbound_email).bounce_missing_user
  end

  def bounce_missing_hcb
    bounce_with HcbCodeReceiptsMailer.with(mail: inbound_email).bounce_missing_hcb
  end

  def bounce_error
    bounce_with HcbCodeReceiptsMailer.with(
      mail: inbound_email,
      reply_to: @hcb_code.receipt_upload_email
    ).bounce_error
  end

  def ensure_permissions?
    return true if @hcb_code.nil?

    authorize @hcb_code, :upload?, policy_class: ReceiptablePolicy

  rescue Pundit::NotAuthorizedError
    # We return with the email equivalent of 404 if you don't have permission
    bounce_with HcbCodeReceiptsMailer.with(mail: inbound_email).bounce_missing_hcb
    false
  end

  def pundit_user
    @user
  end

end
