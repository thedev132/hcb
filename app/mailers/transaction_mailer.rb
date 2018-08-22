class TransactionMailer < ApplicationMailer
  def notify_admin
    @transaction = params[:transaction]

    mail to: admin_email, subject: "[Bank] New Transaction: #{@transaction.name}"
  end
end
