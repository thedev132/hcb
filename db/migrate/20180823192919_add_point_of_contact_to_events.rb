# frozen_string_literal: true

class AddPointOfContactToEvents < ActiveRecord::Migration[5.2]
  def change
    add_reference :events, :point_of_contact, foreign_key: { to_table: :users }
  end
end
