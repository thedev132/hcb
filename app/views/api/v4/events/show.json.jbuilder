# frozen_string_literal: true

json.partial! @event, expand: [:balance_cents, :users]
