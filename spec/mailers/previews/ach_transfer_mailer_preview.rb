# frozen_string_literal: true

class AchTransferMailerPreview < ActionMailer::Preview
  def notify_recipient
    AchTransferMailer.with(ach_transfer:).notify_recipient
  end

  private

  def ach_transfer
    AchTransfer.last
  end

end
