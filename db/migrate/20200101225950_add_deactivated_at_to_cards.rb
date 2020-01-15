class AddDeactivatedAtToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :deactivated_at, :datetime
  end
end
