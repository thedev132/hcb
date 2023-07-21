# frozen_string_literal: true

json.array! @pending_transactions, partial: "api/v4/events/transaction", as: :tx
json.array! @settled_transactions, partial: "api/v4/events/transaction", as: :tx
