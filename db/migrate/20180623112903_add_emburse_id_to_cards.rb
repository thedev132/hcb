class AddEmburseIdToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :emburse_id, :text
  end
end
