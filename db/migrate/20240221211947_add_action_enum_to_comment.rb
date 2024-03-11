class AddActionEnumToComment < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :action, :integer, null: false, default: 0
  end
end
