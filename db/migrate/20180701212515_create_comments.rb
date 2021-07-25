# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.text :content
      t.belongs_to :commentable, polymorphic: true
      t.belongs_to :user

      t.timestamps
    end
    add_index :comments, [:commentable_id, :commentable_type]
  end
end
