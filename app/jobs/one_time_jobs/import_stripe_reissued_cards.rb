# frozen_string_literal: true

# See https://github.com/hackclub/bank/issues/2994

module OneTimeJobs
  class ImportStripeReissuedCards < ApplicationJob
    REISSUED_CARDS = %w[
      ic_1LS0wUFSaumjmb9rHvz6nLAu
      ic_1LS0qxFSaumjmb9ruG4zVhVl
      ic_1LS13yFSaumjmb9r6cuiWXet
      ic_1LS0yIFSaumjmb9rOVvFMCPI
      ic_1LS0uNFSaumjmb9ry69yewHI
      ic_1LS0zjFSaumjmb9ruS52njwU
      ic_1LS13xFSaumjmb9r4MuPjwoU
      ic_1LS1AxFSaumjmb9r8pFSblH5
      ic_1LS1DZFSaumjmb9rAHD5SlPX
      ic_1LS126FSaumjmb9rxJk2apAc
      ic_1LS12XFSaumjmb9rsJgTF6Eu
      ic_1LS0sPFSaumjmb9rDrFKAdos
      ic_1LS12IFSaumjmb9r3tK9Ej4D
      ic_1LS13yFSaumjmb9rNrIAFIew
      ic_1LS15VFSaumjmb9roIBfkKtf
      ic_1LS15WFSaumjmb9rCDbPL2aq
      ic_1LS12XFSaumjmb9rTJej84LU
      ic_1LS16nFSaumjmb9rBtqLpO9q
      ic_1LS125FSaumjmb9rvtyilrl0
      ic_1LS0swFSaumjmb9rKwyx17vJ
      ic_1LS16KFSaumjmb9rgWC0uupL
      ic_1LS11DFSaumjmb9ruufc7QMS
      ic_1LS0yrFSaumjmb9rS2dUbLrc
      ic_1LS157FSaumjmb9rg9XjIFsP
      ic_1LS0sQFSaumjmb9rfADV48c1
      ic_1LS13xFSaumjmb9r5rtGBgsy
      ic_1LS0qAFSaumjmb9rZCgWGSew
    ].freeze

    def perform
      REISSUED_CARDS.each do |stripe_id|
        attrs = get_attrs stripe_id

        card = StripeCard.new attrs
        card.sync_from_stripe!

        # We are skipping callbacks
        card.skip_notify_user = true
        card.skip_pay_for_issuing = true

        card.save
      end
    end

    private

    def get_attrs(stripe_id)
      stripe_obj = Partners::Stripe::Issuing::Cards::Show.new(id: stripe_id).run

      old_stripe_card = StripeCard.find_by_stripe_id(stripe_obj[:replacement_for])
      event = old_stripe_card.event

      {
        stripe_id: stripe_id,
        activated: false,
        purchased_at: nil, # We did not pay for these cards. Stripe covered the costs.
        created_at: stripe_obj[:created],
        replacement_for: old_stripe_card,
        event: event,
        stripe_cardholder: old_stripe_card.stripe_cardholder,
      }
    end

  end
end
