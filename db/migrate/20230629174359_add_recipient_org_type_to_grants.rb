# frozen_string_literal: true

class AddRecipientOrgTypeToGrants < ActiveRecord::Migration[7.0]
  def change
    add_column :grants, :recipient_org_type, :integer
  end

end
