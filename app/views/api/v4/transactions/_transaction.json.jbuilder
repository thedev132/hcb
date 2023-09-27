# frozen_string_literal: true

# This partial is capable of rendering `HcbCode`, `CanonicalPendingTransaction`, and `CanonicalTransactionGrouped` instances

hcb_code = tx.is_a?(HcbCode) ? tx : tx.local_hcb_code

json.id hcb_code.public_id
json.date tx.date
json.amount_cents tx.amount.cents
json.memo hcb_code.memo(event: @event)
json.pending tx.is_a?(CanonicalPendingTransaction) || (tx.is_a?(HcbCode) && tx.pt&.unsettled?)
json.declined (tx.is_a?(CanonicalPendingTransaction) && tx.declined?) || (tx.is_a?(HcbCode) && tx.pt&.declined?)
if Flipper.enabled?(:transaction_tags_2022_07_29, @event)
  json.tags hcb_code.tags do |tag|
    json.id tag.public_id
    json.label tag.label
  end
else
  json.tags []
end
json.code hcb_code.hcb_i1

json.card_charge { json.partial! "api/v4/transactions/card_charge", hcb_code: } if hcb_code.stripe_card? || hcb_code.stripe_force_capture?

json.organization hcb_code.event, partial: "api/v4/events/event", as: :event if local_assigns[:expand]&.include?(:organization)
