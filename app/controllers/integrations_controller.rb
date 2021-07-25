# frozen_string_literal: true

class IntegrationsController < ApplicationController
  include Rails::Pagination

  before_action :set_event
  skip_before_action :signed_in_user, only: [:frankly]
  skip_after_action :verify_authorized # do not force pundit

  def frankly
    # @event = Event.find_by slug: 'hq'
    # transactions have...
    #   date
    #   transaction type [card, check, bank]
    #   amount
    #   memo

    @transactions = []
    # transactions include bank transactions...
    @transactions += @event.transactions.map do |t|
      data = {
        amount: t.amount,
        created_at: t.created_at,
        type: "bank",
        memo: t.display_name,
        uuid: "T#{t.id}"
      }
    end
    # and emburse transactions...
    # @transactions += @event.emburse_transactions.map do |et|
    #   data = {
    #     amount: et.amount,
    #     created_at: et.transaction_time,
    #     type: 'card',
    #     memo: et.merchant_name,
    #     uuid: "ET#{et.id}"
    #   }
    # end
    @paged_transactions = paginate @transactions, per_page: 100
    render json: {
      event: @event.name,
      account_url: event_url(@event),
      donation_url: start_donation_donations_url(@event),
      balance: @event.balance.to_i,
      transactions: @paged_transactions,
    }
  end

  private

  def render_invalid_authorization
    render json: { error: "Unauthorized" }, status: 401
  end

  def set_event
    authenticate_or_request_with_http_token do |bearer_token, _options|
      token = Rails.application.credentials.dig(:mvp_frankly_token)
      api_key = bearer_token.split("|")[0]
      slug = bearer_token.split("|")[1]
      return render_invalid_authorization unless api_key and slug

      @event = Event.find_by slug: slug
      return render_invalid_authorization if @event.nil?

      ActiveSupport::SecurityUtils.secure_compare(api_key, token)
    end
  end
end
