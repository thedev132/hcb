# frozen_string_literal: true

class ReceiptUploadMailer < ApplicationMailer
  def missing_user(inbound_email, params)
    to = params[:to]
    reply_to = params[:reply_to]

    mail to: email.to, reply_to: reply_to
  end

  def missing_hcb(inbound_email, params)
    to = params[:to]
    reply_to = params[:reply_to]

    mail to: to, reply_to: reply_to
  end

  def missing_attachments(inbound_email, params)
    to = params[:to]
    reply_to = params[:reply_to]

    mail to: to, reply_to: reply_to
  end

  def notify_success(inbound_email, params)
    to = params[:to]
    reply_to = params[:reply_to]

    mail to: to, reply_to: reply_to
  end

  def notify_error(inbound_email, params)
    to = params[:to]
    reply_to = params[:reply_to]

    mail to: to, reply_to: reply_to
  end

end
