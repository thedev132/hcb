# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|
      t.references :event, foreign_key: true
      t.text :name
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
