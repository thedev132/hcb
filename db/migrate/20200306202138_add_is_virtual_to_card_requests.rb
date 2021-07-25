# frozen_string_literal: true

class AddIsVirtualToCardRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :card_requests, :is_virtual, :boolean
  end
end
