# frozen_string_literal: true

class AddIpToLoginToken < ActiveRecord::Migration[6.0]
  def change
    add_column :login_tokens, :ip, :string
  end

end
