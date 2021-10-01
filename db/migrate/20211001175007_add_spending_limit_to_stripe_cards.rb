class AddSpendingLimitToStripeCards < ActiveRecord::Migration[6.0]
  def change
    add_column :stripe_cards, :spending_limit_interval, :integer
    add_column :stripe_cards, :spending_limit_amount, :integer
  end
end
