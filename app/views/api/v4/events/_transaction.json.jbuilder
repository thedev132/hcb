# frozen_string_literal: true

json.id tx.local_hcb_code.public_id
json.date tx.date
json.amount_cents tx.amount_cents
json.memo tx.local_hcb_code.memo
json.pending tx.is_a?(CanonicalPendingTransaction)
json.tags tx.local_hcb_code.tags do |tag|
  json.id tag.public_id
  json.label tag.label
end
json.code tx.local_hcb_code.hcb_i1
