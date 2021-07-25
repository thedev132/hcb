# frozen_string_literal: true

class AddDonationIdentifierToDonations < ActiveRecord::Migration[6.0]
  def change
    add_column :donations, :donation_identifier, :string
  end
end
