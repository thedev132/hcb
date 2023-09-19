# frozen_string_literal: true

hcb_code = tx.local_hcb_code

json.id hcb_code.public_id
json.date tx.date
json.amount_cents tx.amount.cents
json.memo hcb_code.memo(event: @event)
json.pending tx.is_a?(CanonicalPendingTransaction)
json.declined tx.is_a?(CanonicalPendingTransaction) && tx.declined?
if Flipper.enabled?(:transaction_tags_2022_07_29, @event)
  json.tags hcb_code.tags do |tag|
    json.id tag.public_id
    json.label tag.label
  end
else
  json.tags []
end
json.code hcb_code.hcb_i1

json.organization hcb_code.event, partial: "api/v4/events/event", as: :event if local_assigns[:expand]&.include?(:organization)
