# frozen_string_literal: true

class AddLast4ToRecurringDonations < ActiveRecord::Migration[7.0]
  def change
    add_column :recurring_donations, :last4_ciphertext, :text
  end

end
