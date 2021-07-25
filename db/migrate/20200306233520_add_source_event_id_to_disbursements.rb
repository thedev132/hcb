# frozen_string_literal: true

class AddSourceEventIdToDisbursements < ActiveRecord::Migration[5.2]
  def change
    add_reference :disbursements, :source_event, foreign_key: { to_table: :events }
  end
end
