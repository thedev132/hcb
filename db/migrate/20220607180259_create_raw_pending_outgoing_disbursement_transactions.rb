# frozen_string_literal: true

class CreateRawPendingOutgoingDisbursementTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :raw_pending_outgoing_disbursement_transactions do |t|
      t.integer :amount_cents
      t.date :date_posted
      t.string :state
      t.references :disbursement,
                   foreign_key: true,
                   index: { name: :index_rpodts_on_disbursement_id }

      t.timestamps
    end
  end

end
