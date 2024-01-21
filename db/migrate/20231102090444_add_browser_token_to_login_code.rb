# frozen_string_literal: true

class AddBrowserTokenToLoginCode < ActiveRecord::Migration[7.0]
  def change
    add_column :login_codes, :browser_token, :string
  end

end
