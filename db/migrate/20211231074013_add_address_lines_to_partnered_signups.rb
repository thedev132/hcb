# frozen_string_literal: true

class AddAddressLinesToPartneredSignups < ActiveRecord::Migration[6.0]
  def change
    add_column :partnered_signups, :owner_address_line1, :string
    add_column :partnered_signups, :owner_address_line2, :string
    add_column :partnered_signups, :owner_address_city, :string
    add_column :partnered_signups, :owner_address_state, :string
    add_column :partnered_signups, :owner_address_postal_code, :text
    add_column :partnered_signups, :owner_address_country, :integer
  end

end
