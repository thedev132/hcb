# frozen_string_literal: true

require "csv"

class PartnerDonationsController < ApplicationController
  include SetEvent
  before_action :set_event, only: [:export]

  def show
    @partner_donation = PartnerDonation.find(params[:id])

    authorize @partner_donation

    # Unpaid PDN don't have a transaction associated with it!
    raise ActiveRecord::RecordNotFound if @partner_donation.unpaid?

    @hcb_code = HcbCode.find_or_create_by(hcb_code: @partner_donation.hcb_code)
    redirect_to hcb_code_path(@hcb_code)
  end

  def export
    authorize @event.partner_donations.first
    head :ok
  end

end
