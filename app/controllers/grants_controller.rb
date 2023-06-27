# frozen_string_literal: true

class GrantsController < ApplicationController
  include SetEvent

  before_action :set_event, only: [:index, :new, :create]

  skip_before_action :signed_in_user, only: [:show]
  skip_after_action :verify_authorized, only: [:show]

  def index
    @grants = @event.grants.order(created_at: :desc)

    authorize @event, policy_class: GrantPolicy
  end

  def new
    @grant = @event.grants.build

    authorize @grant
  end

  def create
    @grant = @event.grants.build(grant_params.merge(submitted_by: current_user))

    authorize @grant

    @grant.save!

    redirect_to event_grants_path(@event), flash: { success: "Your grant has been submitted!" }

  rescue => e
    flash.now[:error] = e.message
    notify_airbrake(e)
    render "new", status: :unprocessable_entity
  end

  def approve
    @grant = authorize Grant.find(params[:grant_id])
    @grant.mark_approved!
    redirect_to grant_process_admin_path(@grant), flash: { success: "Grant approved!" }
  end

  def reject
    @grant = authorize Grant.find(params[:grant_id])
    @grant.mark_rejected!
    redirect_to grant_process_admin_path(@grant), flash: { error: "Grant rejected." }
  end

  def additional_info_needed
    @grant = authorize Grant.find(params[:grant_id])
    @grant.mark_additional_info_needed!
    redirect_to grant_process_admin_path(@grant), flash: { success: 'Grant marked "additional info needed".' }
  end

  def show
    @grant = Grant.find_by_hashid!(params[:id])

    return not_found unless @grant.waiting_on_recipient? || @grant.verifying? || @grant.fulfilled?

    if !signed_in?
      return redirect_to auth_users_path(email: @grant.recipient.email, return_to: grant_path(@grant)), flash: { info: "Please sign in to continue." }
    end

    authorize @grant

  rescue Pundit::NotAuthorizedError
    redirect_to auth_users_path(email: @grant.recipient.email, return_to: grant_path(@grant)), flash: { info: "Please sign in with the same email you received the invitation at." }
  end

  def activate
    @grant = Grant.find_by_hashid!(params[:id])

    return not_found unless @grant.waiting_on_recipient?

    authorize @grant

    grant_params = params.require(:grant).permit(:receipt_method, ach_transfer: [:recipient_name, :routing_number, :account_number], event: [:name])

    ActiveRecord::Base.transaction do
      @grant.update!(receipt_method: grant_params[:receipt_method])

      if @grant.receipt_method_new_organization?
        event = EventService::Create.new(
          name: grant_params[:event][:name],
          point_of_contact_id: @grant.event.point_of_contact_id,
          emails: [@grant.recipient.email],
          category: "grant recipient",
          is_public: false,
          is_indexable: false,
          approved: true,
          sponsorship_fee: 0,
        ).run

        @grant.disbursement = DisbursementService::Create.new(
          source_event_id: @grant.event.id,
          destination_event_id: event.id,
          name: "Grant to #{event.name}",
          amount: @grant.amount,
          requested_by_id: nil,
          fulfilled_by_id: nil,
        ).run

        @grant.disbursement.mark_approved!

        @grant.mark_fulfilled!
      elsif @grant.receipt_method_ach_transfer?
        @grant.ach_transfer = AchTransferService::Create.new(
          event_id: @grant.event_id,
          routing_number: grant_params[:ach_transfer][:routing_number],
          account_number: grant_params[:ach_transfer][:account_number],
          bank_name: nil,
          recipient_name: grant_params[:ach_transfer][:recipient_name],
          recipient_tel: nil,
          amount_cents: @grant.amount_cents,
          payment_for: "Grant to #{grant_params[:ach_transfer][:recipient_name]}",
          current_user: nil,
          scheduled_on: nil,
        ).run

        @grant.mark_verifying!
      end

      @grant.canonical_pending_transaction.decline! # make the pending transaction disappear from the ledger
    end

    redirect_back_or_to grant_path(@grant)

  end

  private

  def grant_params
    params.require(:grant).permit(:amount, :reason, :email, :recipient_name, :recipient_organization, :ends_at)
  end

end
