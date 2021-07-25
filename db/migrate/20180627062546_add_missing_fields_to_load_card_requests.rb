# frozen_string_literal: true

class AddMissingFieldsToLoadCardRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :load_card_requests, :accepted_at, :timestamp
    add_column :load_card_requests, :rejected_at, :timestamp
    add_column :load_card_requests, :canceled_at, :timestamp
  end
end
