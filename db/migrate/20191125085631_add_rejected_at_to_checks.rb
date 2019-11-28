class AddRejectedAtToChecks < ActiveRecord::Migration[5.2]
  def change
    add_column :checks, :rejected_at, :datetime
  end
end
