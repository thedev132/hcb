# frozen_string_literal: true

class AddMessageToRecurringDonations < ActiveRecord::Migration[7.0]
  def change
    add_column :recurring_donations, :message, :text
  end

end
