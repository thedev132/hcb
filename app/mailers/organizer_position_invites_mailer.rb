class OrganizerPositionInvitesMailer < ApplicationMailer
  def notify
    @invite = params[:invite]

    mail to: @invite.email,
      subject: "[Action Requested] You've been invited to the Hack Club Bank"
  end
end
