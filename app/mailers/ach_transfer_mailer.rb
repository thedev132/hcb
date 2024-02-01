# frozen_string_literal: true

class AchTransferMailer < ApplicationMailer
  def notify_failed
    @ach_transfer = params[:ach_transfer]
    @reason = params[:reason]

    mail subject: "[HCB] ACH transfer to #{@ach_transfer.recipient_name} failed to send", to: @ach_transfer.creator.email
  end

end
