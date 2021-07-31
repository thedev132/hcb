# frozen_string_literal: true

class AddStripeApiKeyCiphertextToPartners < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :stripe_api_key_ciphertext, :text
  end
end
