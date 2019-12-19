class DonationMailer < ApplicationMailer
  def donor_receipt
    @donation = params[:donation]

    mail to: @donation.email, subject: "Your receipt for donating #{render_money @donation.amount} to #{@donation.event.name}"
  end
end
