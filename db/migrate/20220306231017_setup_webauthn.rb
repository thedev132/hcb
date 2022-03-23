# frozen_string_literal: true

class SetupWebauthn < ActiveRecord::Migration[6.0]
  def change
    create_table :webauthn_credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :webauthn_id
      t.string :public_key
      t.integer :sign_count

      t.timestamps
    end

    add_column :users, :webauthn_id, :string
  end

end
