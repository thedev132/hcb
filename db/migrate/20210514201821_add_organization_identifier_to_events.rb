# frozen_string_literal: true

class AddOrganizationIdentifierToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :organization_identifier, :string
  end
end
