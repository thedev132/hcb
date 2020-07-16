# Preview all emails at http://localhost:3000/rails/mailers/emburse_card_request_mailer
class DonationMailerPreview < ActionMailer::Preview
  def donor_receipt
    config = {
      donation: Donation.last
    }

    DonationMailer.with(config).send __method__
  end

  def first_donation_notification
    config = {
      donation: Donation.last
    }

    DonationMailer.with(config).send __method__
  end
end