class IntegrationsController < ApplicationController
  include Rails::Pagination

  before_action :authenticate
  skip_before_action :signed_in_user, only: [:frankly]
  skip_after_action :verify_authorized # do not force pundit

  def frankly
    @event = Event.find_by slug: 'hq'
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
        type: 'bank',
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

  def authenticate
    authenticate_or_request_with_http_token do |bearer_token, _options|
      token = Rails.application.credentials.dig(:mvp_frankly_token)
      ActiveSupport::SecurityUtils.secure_compare(bearer_token, token)
    end
  end
end
