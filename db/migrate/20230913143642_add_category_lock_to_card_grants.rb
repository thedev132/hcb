# frozen_string_literal: true

class AddCategoryLockToCardGrants < ActiveRecord::Migration[7.0]
  def change
    add_column :card_grants, :category_lock, :string
  end

end
