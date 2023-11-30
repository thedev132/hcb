# frozen_string_literal: true

class ReceiptBinMailer < ApplicationMailer
  before_action { @inbound_mail = params[:mail] }
  before_action { @reply_to = params[:reply_to] }
  before_action { @to = params[:to] || @inbound_mail&.mail&.from&.first }

  default to: -> { @to },
          reply_to: -> { @reply_to },
          subject: -> { @inbound_mail&.mail&.subject }

  def bounce_missing_user
    mail subject: "Unknown Receipt Bin inbox"
  end

  def bounce_missing_attachment
    mail subject: "Missing attachment(s)"
  end

  def bounce_success
    @receipts_count = params[:receipts_count]
    mail subject: "Thank you for your #{"receipt".pluralize(@receipts_count)}!"
  end

  def bounce_error
    mail subject: "An unknown error occured"
  end

end
