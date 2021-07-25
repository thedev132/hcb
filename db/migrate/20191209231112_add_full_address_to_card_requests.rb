# frozen_string_literal: true

class AddFullAddressToCardRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :card_requests, :shipping_address_street_one, :string
    add_column :card_requests, :shipping_address_street_two, :string
    add_column :card_requests, :shipping_address_city, :string
    add_column :card_requests, :shipping_address_state, :string
    add_column :card_requests, :shipping_address_zip, :string
  end
end
