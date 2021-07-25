# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.integer :api_id
      t.text :api_access_token

      t.timestamps
    end
  end
end
