# frozen_string_literal: true

json.partial! "transaction", tx: @hcb_code, expand: ([:organization] if params[:event_id].blank?)
