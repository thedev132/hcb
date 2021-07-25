# frozen_string_literal: true

class FlipLcrTransactionReference < ActiveRecord::Migration[5.2]
  def change
    remove_reference :load_card_requests, :transaction
    add_reference :transactions, :load_card_request, foreign_key: true
  end
end
