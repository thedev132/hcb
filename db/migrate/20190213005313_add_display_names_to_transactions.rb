class AddDisplayNamesToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :display_name, :text

    reversible do |dir|
      dir.up { Transaction.update_all('display_name = name') }
    end
  end
end
