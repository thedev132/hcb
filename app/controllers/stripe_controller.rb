class StripeController < ApplicationController
  protect_from_forgery except: :webhook # ignore csrf checks
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user, only: [:webhook] # do not require logged in user

  def webhook
    payload = request.body.read
    event = nil
    
    begin
      event = StripeService::Event.construct_from(
        JSON.parse(payload, symbolize_names: true)
      )
      method = "handle_" + event['type'].tr('.', '_')
      self.send method, event
    rescue JSON::ParserError => e
      head 400
      return
    rescue NoMethodError => e
      puts e
      head 400
      return
    end

    head 200
  end

  private

  def handle_issuing_authorization_request(event)
    ::StripeAuthorizationService::Webhook::HandleIssuingAuthorizationRequest.new(stripe_event: event).run
  end

  def handle_issuing_authorization_updated(event)
    # This is to listen for edge-cases like multi-capture TXs
    # https://stripe.com/docs/issuing/purchases/transactions
    auth = event[:data][:object]
    sa = StripeAuthorization.find_or_initialize_by(stripe_id: auth[:id])
    sa.sync_from_stripe!
    sa.save
  end
  # This is to listen for declined authorizations before the 'issuing_authorization.request' hook.
  # ex. An authorization for an inactive card
  alias_method :handle_issuing_authorization_created, :handle_issuing_authorization_updated

  def handle_issuing_transaction_created(event)
    tx = event[:data][:object]
    amount = tx[:amount]
    return unless amount < 0
    TopupStripeJob.perform_later
  end

  def handle_issuing_card_updated(event)
    card = StripeCard.find_by(stripe_id: event[:data][:object][:id])
    card.sync_from_stripe!
    card.save
  end
end
