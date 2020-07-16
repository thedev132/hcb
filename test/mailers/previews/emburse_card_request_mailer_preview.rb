# Preview all emails at http://localhost:3000/rails/mailers/emburse_card_request_mailer
class EmburseCardRequestMailerPreview < ActionMailer::Preview
  def accepted_physical
    config = {
      emburse_card_request: EmburseCard.where(is_virtual: false).last.emburse_card_request
    }

    EmburseCardRequestMailer.with(config).send __method__
  end

  def accepted_virtual
    config = {
      emburse_card_request: EmburseCard.where(is_virtual: true).last.emburse_card_request
    }

    EmburseCardRequestMailer.with(config).send __method__
  end
end