# frozen_string_literal: true

class IncreaseCheckMailer < ApplicationMailer
  def notify_recipient
    @check = params[:check]

    mail to: @check.recipient_email, subject: "Your check from #{@check.event.name} is in transit", from: "#{@check.event.name} via HCB <hcb@hackclub.com>"

  end

end
