# frozen_string_literal: true

class AddCanceledAtToRecurringDonations < ActiveRecord::Migration[7.0]
  def change
    add_column :recurring_donations, :canceled_at, :datetime
  end

end
