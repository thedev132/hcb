# frozen_string_literal: true

pagination_metadata(json)

json.data @transactions, partial: "api/v4/events/transaction", as: :tx
