# frozen_string_literal: true

class DropApiKeyFromPartners < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :partners, :api_key
    end
  end

end
