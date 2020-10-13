class AddPurchasedAtToStripeCards < ActiveRecord::Migration[6.0]
  def change
    add_column :stripe_cards, :purchased_at, :timestamp
  end
end
