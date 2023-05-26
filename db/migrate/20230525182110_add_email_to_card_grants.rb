# frozen_string_literal: true

class AddEmailToCardGrants < ActiveRecord::Migration[7.0]
  def change
    add_column :card_grants, :email, :string, null: false
  end

end
