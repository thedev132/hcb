# frozen_string_literal: true

class SupportSmsAuth < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :phone_number_verified, :boolean, default: false
    add_column :users, :use_sms_auth, :boolean, default: false
  end
end
