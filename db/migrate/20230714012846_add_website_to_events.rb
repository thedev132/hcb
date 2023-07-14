# frozen_string_literal: true

class AddWebsiteToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :website, :string
  end

end
