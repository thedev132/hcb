class StripeCardMailer < ApplicationMailer
  def physical_card_ordered
    @card = params[:card]
    @user = @card.user
    @event = @card.event
    @recipient = @user.email
    mail to: @recipient,
         subject: "Your new Hack Club Bank card for #{@event.name} is on its way"
  end
end
