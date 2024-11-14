# frozen_string_literal: true

class AdminMailerPreview < ActionMailer::Preview
  def reminders
    AdminMailer.reminders
  end

end
