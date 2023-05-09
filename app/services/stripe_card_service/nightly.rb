# frozen_string_literal: true

module StripeCardService
  class Nightly
    def run
      rename_canonical_transaction
    end

    private

    # [@garyhtou] This really should be done via linking the CT to a Stripe Card
    # via an new HCB Code type.
    #
    #   The HCB Code's memo would use a default custom stripe card memo that
    #   supersedes the CT's default memo (from plaid). That default custom
    #   stripe card memo in the HCB Code would be superseded by the CT's
    #   custom memo (if it exists).
    #
    #   Check out HcbCode#memo for more info on how this work.
    def rename_canonical_transaction
      stripe_issuing_card_canoncial_transactons_to_rename.each do |ct|
        ::CanonicalTransactionService::SetCustomMemo.new(
          canonical_transaction_id: ct.id,
          custom_memo: "💳 New user card fee"
        ).run
      end
    end

    def stripe_issuing_card_canoncial_transactons_to_rename
      CanonicalTransaction.likely_hack_club_bank_issued_cards.without_custom_memo
    end

  end
end
