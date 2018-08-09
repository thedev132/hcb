class EmburseTransactionsMailer < ApplicationMailer
  def notify(params)
    @emburse_transaction = params[:emburse_transaction]
    env = Rails.env.production? ? :prod : :dev

    mail to: Rails.application.credentials.admin_email[env],
      subject: "[Action Requested] No department linked to Emburse transaction ##{@emburse_transaction.id}"
  end
end
