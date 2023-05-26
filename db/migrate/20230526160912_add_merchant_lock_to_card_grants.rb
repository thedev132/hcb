# frozen_string_literal: true

class AddMerchantLockToCardGrants < ActiveRecord::Migration[7.0]
  def change
    add_column :card_grants, :merchant_lock, :string
  end

end
