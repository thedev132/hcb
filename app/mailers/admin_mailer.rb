# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def opdr_notification
    @opdr = params[:opdr]

    mail to:, subject: "[OPDR] #{@opdr.event.name} / #{@opdr.organizer_position.user.name}"
  end

  private

  def to
    "hcb-promotions-aaaafacn32rulnb3zkd3h75afm@hackclub.slack.com"
  end

end
