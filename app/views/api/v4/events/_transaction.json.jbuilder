# frozen_string_literal: true

json.id tx.local_hcb_code.public_id
json.date tx.date
json.amount_cents tx.amount_cents
json.memo tx.local_hcb_code.memo
json.pending tx.is_a?(CanonicalPendingTransaction)
json.declined tx.is_a?(CanonicalPendingTransaction) && tx.declined?
if Flipper.enabled?(:transaction_tags_2022_07_29, @event)
  json.tags tx.local_hcb_code.tags do |tag|
    json.id tag.public_id
    json.label tag.label
  end
else
  json.tags []
end
json.code tx.local_hcb_code.hcb_i1
