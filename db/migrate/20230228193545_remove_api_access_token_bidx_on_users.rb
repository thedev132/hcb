# frozen_string_literal: true

class RemoveApiAccessTokenBidxOnUsers < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :users, :api_access_token_bidx
    end
  end

end
