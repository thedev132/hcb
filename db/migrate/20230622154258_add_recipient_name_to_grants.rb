# frozen_string_literal: true

class AddRecipientNameToGrants < ActiveRecord::Migration[7.0]
  def change
    add_column :grants, :recipient_name, :string
  end

end
