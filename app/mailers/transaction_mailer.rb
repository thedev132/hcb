class TransactionMailer < ApplicationMailer
  def notify_admin
    @transaction = params[:transaction]
    env = Rails.env.production? ? :prod : :dev

    mail to: Rails.application.credentials.admin_email[env],
      subject: "[Bank] New Transaction: #{@transaction.name}"
  end
end
