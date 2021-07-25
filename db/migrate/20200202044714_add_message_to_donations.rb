# frozen_string_literal: true

class AddMessageToDonations < ActiveRecord::Migration[5.2]
  def change
    add_column :donations, :message, :text
  end
end
