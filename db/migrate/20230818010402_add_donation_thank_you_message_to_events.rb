# frozen_string_literal: true

class AddDonationThankYouMessageToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :donation_thank_you_message, :text
  end

end
