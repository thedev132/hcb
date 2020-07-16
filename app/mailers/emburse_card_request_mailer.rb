class EmburseCardRequestMailer < ApplicationMailer
  def accepted_physical
    @request = params[:emburse_card_request]
    @recipient = @request.creator.email
    @emburse_card = @request.emburse_card
    @name = @request.full_name
    @last_four = @emburse_card.last_four
    @event = @emburse_card.event.name
    @activation_link = @emburse_card.emburse_path

    mail to: @recipient,
      subject: "Your #{@event} credit emburse_card is on the way!"
  end

  def accepted_virtual
    @request = params[:emburse_card_request]
    @recipient = @request.creator.email
    @emburse_card = @request.emburse_card
    @name = @request.full_name
    @last_four = @emburse_card.last_four
    @event = @emburse_card.event.name
    @activation_link = @emburse_card.emburse_path

    mail to: @recipient,
      subject: "Your #{@event} virtual emburse_card is ready!"
  end
end
