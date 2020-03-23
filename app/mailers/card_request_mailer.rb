class CardRequestMailer < ApplicationMailer
  def accepted_physical
    @request = params[:card_request]
    @recipient = @request.creator.email
    @card = @request.card
    @name = @request.full_name
    @last_four = @card.last_four
    @event = @card.event.name
    @activation_link = @card.emburse_path

    mail to: @recipient,
      subject: "Your #{@event} credit card is on the way!"
  end

  def accepted_virtual
    @request = params[:card_request]
    @recipient = @request.creator.email
    @card = @request.card
    @name = @request.full_name
    @last_four = @card.last_four
    @event = @card.event.name
    @activation_link = @card.emburse_path

    mail to: @recipient,
      subject: "Your #{@event} virtual card is ready!"
  end
end
