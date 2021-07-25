# frozen_string_literal: true

class AddPublicMessageToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :public_message, :text
  end
end
