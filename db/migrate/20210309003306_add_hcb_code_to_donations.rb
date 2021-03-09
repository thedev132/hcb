class AddHcbCodeToDonations < ActiveRecord::Migration[6.0]
  def change
    add_column :donations, :hcb_code, :text
  end
end
