# frozen_string_literal: true

class AddGeocodeToLoginToken < ActiveRecord::Migration[6.0]
  def change
    add_column :login_tokens, :latitude, :decimal
    add_column :login_tokens, :longitude, :decimal
  end

end
