# frozen_string_literal: true

class AddEventToTag < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :tags, :event, null: false, index: { algorithm: :concurrently }
  end

end
