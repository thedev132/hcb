class DropAppIdFromUsers < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      remove_index :users, :api_id
      remove_column :users, :api_id
    end
  end
end
