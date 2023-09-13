# frozen_string_literal: true

class CardGrantsController < ApplicationController
  include SetEvent

  skip_before_action :signed_in_user, only: [:show]
  skip_after_action :verify_authorized, only: [:show]

  before_action :set_event, only: %i[new create]

  def new
    @card_grant = @event.card_grants.build

    authorize @card_grant

    last_card_grant = @event.card_grants.order(created_at: :desc).first

    if last_card_grant.present?
      @card_grant.amount_cents = last_card_grant.amount_cents
      @card_grant.merchant_lock = last_card_grant.merchant_lock
      @card_grant.category_lock = last_card_grant.category_lock
    end
  end

  def create
    params[:card_grant][:amount_cents] = Monetize.parse(params[:card_grant][:amount_cents]).cents
    @card_grant = @event.card_grants.build(params.require(:card_grant).permit(:amount_cents, :email, :merchant_lock, :category_lock).merge(sent_by: current_user))

    authorize @card_grant

    @card_grant.save!

    flash[:success] = "Successfully sent a grant to #{@card_grant.email}!"

  rescue => e
    flash[:error] = "Something went wrong. #{e.message}"
    notify_airbrake(e)
  ensure
    redirect_to event_transfers_path(@event)
  end

  def show
    @card_grant = CardGrant.find_by_hashid!(params[:id])

    if !signed_in?
      return redirect_to auth_users_path(email: @card_grant.user.email, return_to: card_grant_path(@card_grant)), flash: { info: "Please sign in to continue." }
    end

    authorize @card_grant

    @card = @card_grant.stripe_card
    @hcb_codes = @card&.hcb_codes

  rescue Pundit::NotAuthorizedError
    redirect_to auth_users_path(email: @card_grant.user.email, return_to: card_grant_path(@card_grant)), flash: { info: "Please sign in with the same email you received the invitation at." }
  end

  def activate
    @card_grant = CardGrant.find_by_hashid(params[:id])
    authorize @card_grant

    @card_grant.create_stripe_card(current_session)

    redirect_to @card_grant
  end

end
