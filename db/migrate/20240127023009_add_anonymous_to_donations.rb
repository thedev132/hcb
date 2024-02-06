class AddAnonymousToDonations < ActiveRecord::Migration[7.0]
  def change
    add_column :donations, :anonymous, :boolean, default: false, null: false
  end

end
