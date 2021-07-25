# frozen_string_literal: true

class CentralController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  before_action :signed_in_admin

  def index
  end

  def ledger
    event_id = params[:event_id].present? ? params[:event_id] : nil
    page = params[:page] || 1

    if event_id
      @event = Event.find(event_id)
      @canonical_transactions = @event.canonical_transactions.order("date desc").page(page).per(250)
      @account_balance_cents = @event.canonical_transactions.sum(:amount_cents)
      @account_absolute_balance_cents = @event.canonical_transactions.sum("abs(amount_cents)")
    else
      @canonical_transactions = CanonicalTransaction.order("date desc").page(page).per(250)
      @account_balance_cents = CanonicalTransaction.sum(:amount_cents)
      @account_absolute_balance_cents = CanonicalTransaction.sum("abs(amount_cents)")
    end
  end
end
