# frozen_string_literal: true

class AddErroredAtToDisbursements < ActiveRecord::Migration[6.0]
  def change
    add_column :disbursements, :errored_at, :datetime
  end
end
