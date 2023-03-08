# frozen_string_literal: true

class CanonicalPendingTransactionMailerPreview < ActionMailer::Preview
  def notify_approved
    # @cpt = CanonicalPendingTransaction.stripe.last
    @cpt = CanonicalPendingTransaction.stripe.where("amount_cents < ?", -1_000_00).last

    CanonicalPendingTransactionMailer.with(
      canonical_pending_transaction_id: @cpt.id,
    ).notify_approved
  end

end
