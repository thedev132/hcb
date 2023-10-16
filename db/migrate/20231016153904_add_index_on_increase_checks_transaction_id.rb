# frozen_string_literal: true

class AddIndexOnIncreaseChecksTransactionId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :increase_checks, "((increase_object->'deposit'->>'transaction_id')::text)", algorithm: :concurrently, name: :index_increase_checks_on_transaction_id
  end

end
