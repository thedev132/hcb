# frozen_string_literal: true

class AddMissingFieldsToCardRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :card_requests, :shipping_address, :text
    add_column :card_requests, :full_name, :string
    add_column :card_requests, :rejected_at, :timestamp
    add_column :card_requests, :accepted_at, :timestamp
    add_column :card_requests, :canceled_at, :timestamp
    add_column :card_requests, :notes, :text
  end
end
