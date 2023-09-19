# frozen_string_literal: true

pagination_metadata(json)

json.data @hcb_codes, partial: "api/v4/events/transaction", as: :tx, expand: [:organization]
