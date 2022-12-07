# frozen_string_literal: true

class AddProcessorToAchTransfer < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :ach_transfers, :processor, null: true, index: { algorithm: :concurrently }
  end

end
