# frozen_string_literal: true

class AddDisbursementToCardGrants < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :card_grants, :disbursement, null: false, index: { algorithm: :concurrently }
  end

end
