# frozen_string_literal: true

class DonationMailer < ApplicationMailer
  def donor_receipt
    @donation = params[:donation]

    mail to: @donation.email, subject: "Receipt for your donation to #{@donation.event.name}"
  end

  def first_donation_notification
    @donation = params[:donation]
    @emails = @donation.event.users.map { |u| u.email }

    mail to: @emails, subject: "Congrats on receiving your first donation! 🎉"
  end
end
