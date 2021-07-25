# frozen_string_literal: true

class AddDonationPageEnabledAndDonationPageMessageToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :donation_page_enabled, :boolean
    add_column :events, :donation_page_message, :text
  end
end
