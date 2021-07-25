# frozen_string_literal: true

class FixCardReferenceToCardRequest < ActiveRecord::Migration[5.2]
  def change
    remove_reference :cards, :card_request
    add_reference :card_requests, :card, foreign_key: true
  end
end
