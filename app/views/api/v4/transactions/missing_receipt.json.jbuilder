# frozen_string_literal: true

pagination_metadata(json)

json.data @hcb_codes, partial: "api/v4/transactions/transaction", as: :tx, expand: [:organization]
