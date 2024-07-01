# frozen_string_literal: true

class UserSessionMailer < ApplicationMailer
  def new_login(session:)
    @session = session
    @user = session.user

    mail to: @user.email, subject: "New login to your HCB account"
  end

end
