# frozen_string_literal: true

class AddCountryToSponsor < ActiveRecord::Migration[7.0]
  def change
    add_column :sponsors, :address_country, :text, default: "US"

  end

end
