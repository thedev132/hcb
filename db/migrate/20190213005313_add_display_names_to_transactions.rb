# frozen_string_literal: true

class AddDisplayNamesToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :display_name, :text

    reversible do |dir|
      dir.up { Transaction.find_each(&:set_default_display_name) }
    end
  end
end
