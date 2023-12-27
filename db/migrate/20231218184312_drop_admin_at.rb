class DropAdminAt < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :users, :admin_at, :datetime
    end
  end
end
