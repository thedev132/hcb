# frozen_string_literal: true

class OrganizerPositionInvitesMailer < ApplicationMailer
  def notify
    @invite = params[:invite]

    mail to: @invite.email, subject: "You've been invited to join #{@invite.event.name} on Hack Club Bank 🚀"
  end
end
