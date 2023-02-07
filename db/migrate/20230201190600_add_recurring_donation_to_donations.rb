# frozen_string_literal: true

class AddRecurringDonationToDonations < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :donations, :recurring_donation, null: true, index: { algorithm: :concurrently }
  end

end
