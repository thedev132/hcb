# frozen_string_literal: true

class IncreaseCheckMailerPreview < ActionMailer::Preview
  def notify_recipient
    IncreaseCheckMailer.with(check:).notify_recipient
  end

  private

  def check
    IncreaseCheck.last
  end

end
