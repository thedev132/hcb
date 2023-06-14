# frozen_string_literal: true

class AddIncreaseAccountIdToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :increase_account_id, :string, null: false, default: IncreaseService::AccountIds::FS_MAIN
    change_column_default :events, :increase_account_id, nil
  end

end
