# frozen_string_literal: true

class AddInviteMessageToCardGrantSetting < ActiveRecord::Migration[7.0]
  def change
    add_column :card_grant_settings, :invite_message, :string, null: true
  end

end
