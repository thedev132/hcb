class CentralController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  before_action :signed_in_admin

  def index
  end

  def ledger
    event_id = params[:event_id].present? ? params[:event_id] : nil
    page = params[:page] || 1

    if event_id
      @canonical_transactions = Event.find(event_id).canonical_transactions.order("date desc").page(page).per(500)
    else
      @canonical_transactions = CanonicalTransaction.order("date desc").page(page).per(500)
    end
  end
end
