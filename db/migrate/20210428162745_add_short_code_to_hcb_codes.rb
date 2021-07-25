# frozen_string_literal: true

class AddShortCodeToHcbCodes < ActiveRecord::Migration[6.0]
  def change
    add_column :hcb_codes, :short_code, :text
  end
end
