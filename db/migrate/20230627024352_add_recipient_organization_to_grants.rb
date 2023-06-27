# frozen_string_literal: true

class AddRecipientOrganizationToGrants < ActiveRecord::Migration[7.0]
  def change
    add_column :grants, :recipient_organization, :string
  end

end
