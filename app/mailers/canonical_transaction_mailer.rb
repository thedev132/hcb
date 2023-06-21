# frozen_string_literal: true

class CanonicalTransactionMailer < ApplicationMailer
  def export_ready(event:, user:, mime_type:, title:, content:)
    @event = event
    @user = user
    @mime_type = mime_type
    @title = title
    @content = content
    # Once file sizes become large, we'll need to upload to S3 and provide a
    # download link. However, we are not at that point just yet.
    attachments[title] = { mime_type:, content: }

    mail to: @user.email, subject: "Your transaction export for #{event.name} is ready!"
  end

end
