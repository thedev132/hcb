# frozen_string_literal: true

class MakeCardGrantStripeCardIdNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:card_grants, :stripe_card_id, true)
    change_column_null(:card_grants, :subledger_id, true)
    change_column_null(:card_grants, :disbursement_id, true)
  end

end
