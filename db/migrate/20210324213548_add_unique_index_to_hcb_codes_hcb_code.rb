class AddUniqueIndexToHcbCodesHcbCode < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    remove_index :hcb_codes, :hcb_code
    add_index :hcb_codes, :hcb_code, unique: true, algorithm: :concurrently
  end
end
