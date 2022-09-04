# frozen_string_literal: true

class DropApiAccessTokenOnUsers < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :users, :api_access_token
    end
  end

end
