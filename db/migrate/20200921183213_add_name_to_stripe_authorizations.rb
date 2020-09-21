class AddNameToStripeAuthorizations < ActiveRecord::Migration[6.0]
  def change
    add_column :stripe_authorizations, :name, :string
    add_column :stripe_authorizations, :display_name, :string
  end
end
