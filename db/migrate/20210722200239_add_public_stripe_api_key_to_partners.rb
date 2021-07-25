# frozen_string_literal: true

class AddPublicStripeApiKeyToPartners < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :public_stripe_api_key, :string
  end
end
