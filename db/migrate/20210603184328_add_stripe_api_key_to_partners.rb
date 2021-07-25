# frozen_string_literal: true

class AddStripeApiKeyToPartners < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :stripe_api_key, :string
  end
end
