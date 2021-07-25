# frozen_string_literal: true

class CheckMailer < ApplicationMailer
  def undeposited
    @check = params[:check]

    mail to: admin_email, subject: "Check #{@check.check_number} wasn't deposited & is being voided."
  end

  def undeposited_organizers
    @check = params[:check]
    @emails = @check.event.users.map { |u| u.email }
    @event = @check.event

    mail to: @emails, subject: "Your check to #{@check.lob_address.name}"
  end
end
