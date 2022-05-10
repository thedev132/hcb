# frozen_string_literal: true

class ReceiptUploadMailer < ApplicationMailer
  before_action { @inbound_mail = params[:mail] }
  before_action { @reply_to = params[:reply_to] }

  default to: -> { @inbound_mail.mail.from.first },
          reply_to: -> { @reply_to },
          subject: -> { @inbound_mail.mail.subject }

  def bounce_missing_user
    mail
  end

  def bounce_missing_hcb
    @to = @inbound_mail.mail.from.first
    mail
  end

  def bounce_missing_attachment
    mail
  end

  def bounce_success
    @receipts_count = params[:receipts_count]
    mail
  end

  def bounce_error
    mail
  end

end
