class AddAnonymousToRecurringDonation < ActiveRecord::Migration[7.0]
  def change
    add_column :recurring_donations, :anonymous, :boolean, default: false, null: false
  end

end
