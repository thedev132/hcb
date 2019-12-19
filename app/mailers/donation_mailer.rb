class DonationMailer < ApplicationMailer
  def donor_receipt
    @donation = params[:donation]

    mail to: @donation.email, subject: "Receipt for your donation to #{@donation.event.name}"
  end
end
