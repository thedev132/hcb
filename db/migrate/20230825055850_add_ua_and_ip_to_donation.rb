# frozen_string_literal: true

class AddUaAndIpToDonation < ActiveRecord::Migration[7.0]
  def change
    add_column :donations, :user_agent, :text
    add_column :donations, :ip_address, :inet
  end

end
