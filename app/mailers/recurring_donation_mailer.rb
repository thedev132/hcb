# frozen_string_literal: true

class RecurringDonationMailer < ApplicationMailer
  def amount_changed
    @recurring_donation = params[:recurring_donation]
    @previous_amount = params[:previous_amount]

    mail to: @recurring_donation.email, subject: "[#{@recurring_donation.event.name}] Donation amount updated"
  end

  def payment_method_changed
    @recurring_donation = params[:recurring_donation]

    mail to: @recurring_donation.email, subject: "[#{@recurring_donation.event.name}] Payment details updated"
  end

  def canceled
    @recurring_donation = params[:recurring_donation]

    mail to: @recurring_donation.email, subject: "[#{@recurring_donation.event.name}] Donation canceled"
  end

end
