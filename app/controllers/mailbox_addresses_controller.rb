# frozen_string_literal: true

class MailboxAddressesController < ApplicationController
  def create
    @mailbox_address = current_user.mailbox_addresses.build

    authorize @mailbox_address

    current_user.mailbox_addresses.previewed.destroy_all

    if @mailbox_address.save
      redirect_to @mailbox_address
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    mailbox_address = current_user.mailbox_addresses.find(params[:id])

    authorize mailbox_address

    if mailbox_address.activated?
      @active_address = mailbox_address
    else
      @previewed_address = mailbox_address
      @active_address = current_user.active_mailbox_address
    end
  end

  def activate
    @mailbox_address = current_user.mailbox_addresses.find(params[:id])

    authorize @mailbox_address

    MailboxAddress.transaction do
      current_user.mailbox_addresses.activated.each(&:mark_discarded!)

      @mailbox_address.mark_activated!
    end

    redirect_to @mailbox_address, flash: { success: "Address activated!" }
  rescue ActiveRecord::RecordInvalid
    redirect_to @mailbox_address, flash: { error: "Error activating address" }
  end

end
