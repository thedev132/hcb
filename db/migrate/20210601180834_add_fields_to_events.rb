# frozen_string_literal: true

class AddFieldsToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :owner_name, :string
    add_column :events, :owner_email, :string
    add_column :events, :owner_phone, :string
    add_column :events, :owner_address, :string
    add_column :events, :owner_birthdate, :date
  end
end
