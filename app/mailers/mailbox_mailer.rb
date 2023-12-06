# frozen_string_literal: true

class MailboxMailer < ApplicationMailer
  def forward(incoming_mail:, to:)
    mail to:, subject: "Fwd: #{incoming_mail.subject} (#{incoming_mail.to.first})", reply_to: incoming_mail.from, content: incoming_mail.content
  end

end
