# frozen_string_literal: true

class GrantMailer < ApplicationMailer
  def invitation
    @grant = params[:grant]

    mail to: @grant.recipient.email, subject: "Grant invitation from #{@grant.event.name}", from: "#{@grant.event.name} via HCB <bank@hackclub.com>"
  end

  def approved
    @grant = params[:grant]

    mail to: @grant.submitted_by.email, subject: "Grant to #{@grant.recipient_name} approved and sent"
  end

end
