class RemoveAdminsFromCards < ActiveRecord::Migration[5.2]
  def change
    remove_column :cards, :admin_id
  end
end
