# frozen_string_literal: true

class CardGrantMailer < ApplicationMailer
  def card_grant_notification
    @card_grant = params[:card_grant]

    mail to: @card_grant.user.email, subject: "[#{@card_grant.event.name}] You've received a #{@card_grant.amount.format} grant!"
  end

end
