class RemoveStripeApiKeyFromPartners < ActiveRecord::Migration[6.0]
  def change
    safety_assured { remove_column :partners, :stripe_api_key, :string }
  end
end
