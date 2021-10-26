# frozen_string_literal: true

class ChangeDefaultForPendingTransactionEngineAt < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    change_column_default :events, :pending_transaction_engine_at, DateTime.now
    # @msw TODO: This should be set to a specific time, because DateTime.now will
    # constantly update the schema & cause confusion when staging git changes.
  end
end
