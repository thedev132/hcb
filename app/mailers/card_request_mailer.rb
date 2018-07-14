class CardRequestMailer < ApplicationMailer
  def accepted
    @request = params[:card_request]
    @recipient = @request.creator.email
    @card = @request.card
    @name = @request.full_name
    @last_four = @card.last_four
    @event = @card.event.name
    @activation_link = @card.emburse_path

    mail to: @recipient,
      subject: "Your #{@event} credit card for #{@card.full_name} is on the way"
  end
end
