class StripeCardMailer < ApplicationMailer
  def physical_card_ordered
    @card = StripeCard.find params[:card_id]
    @user = @card.user
    @event = @card.event
    @has_multiple_events = @user.events.size > 1
    @recipient = @user.email
    @eta = @card.stripe_obj.to_hash[:shipping][:eta]

    mail to: @recipient,
         subject: "Your new Hack Club Bank card (ending in #{@card.last4}) for #{@event.name} is on its way"
  end

  def virtual_card_ordered
    @card = StripeCard.find params[:card_id]
    @user = @card.user
    @event = @card.event
    @recipient = @user.email

    mail to: @recipient,
         subject: "New virtual Hack Club Bank card (ending in #{@card.last4}) for #{@event.name}"
  end
end
