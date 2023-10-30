# frozen_string_literal: true

class CreateCardGrantSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :card_grant_settings do |t|
      t.belongs_to :event, null: false, foreign_key: true
      t.string :merchant_lock
      t.string :category_lock
    end
  end

end
