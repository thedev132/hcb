# frozen_string_literal: true

class RemoveNullFalseForPartnerDonationsHcbCodes < ActiveRecord::Migration[6.0]
  def change
    change_column_null :partner_donations, :hcb_code, true
  end
end
