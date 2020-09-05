class StripeCardMailer < ApplicationMailer
  def physical_card_ordered
    @card = params[:card]
    @user = @card.user
    @event = @card.event
    @has_multiple_events = @user.events.size > 1
    @recipient = @user.email

    mail to: @recipient,
         subject: "Your new Hack Club Bank card for #{@event.name} is on its way"
  end
end
