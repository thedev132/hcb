# frozen_string_literal: true

class RemoveDonationIdentifier < ActiveRecord::Migration[6.0]
  def change
    safety_assured {
      remove_column :partner_donations, :donation_identifier, :text
      remove_column :donations, :donation_identifier, :text
    }
  end
end
