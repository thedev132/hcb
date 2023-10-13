# frozen_string_literal: true

class AddStatusToCardGrants < ActiveRecord::Migration[7.0]
  def change
    add_column :card_grants, :status, :integer, default: 0, null: false
  end

end
