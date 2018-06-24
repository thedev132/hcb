class CardRequestMailer < ApplicationMailer
  def accepted
    @recipient = params[:recipient]
    @card = params[:card]
    @name = @card.full_name
    @last_four = @card.last_four
    @event = @card.event.name
    @activation_link = @card.emburse_link

    mail to: @recipient.email,
      subject: "Your #{@event} credit card for #{@card.full_name} is on the way"
  end
end
