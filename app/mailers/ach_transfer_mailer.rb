# frozen_string_literal: true

class AchTransferMailer < ApplicationMailer
  def notify_recipient
    @ach_transfer = params[:ach_transfer]

    mail to: @ach_transfer.recipient_email, subject: "Your ACH transfer from #{@ach_transfer.event.name} is in transit", from: "#{@ach_transfer.event.name} via HCB <hcb@hackclub.com>"
  end

  def notify_failed
    @ach_transfer = params[:ach_transfer]
    @reason = params[:reason]

    mail subject: "[HCB] ACH transfer to #{@ach_transfer.recipient_name} failed to send", to: @ach_transfer.creator.email
  end

end
