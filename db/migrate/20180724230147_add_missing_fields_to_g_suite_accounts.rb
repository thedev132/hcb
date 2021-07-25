# frozen_string_literal: true

class AddMissingFieldsToGSuiteAccounts < ActiveRecord::Migration[5.2]
  class GSuiteAccount < ActiveRecord::Base; end
  class User < ActiveRecord::Base; end

  def change
    add_column :g_suite_accounts, :first_name, :string
    add_column :g_suite_accounts, :last_name, :string

    GSuiteAccount.all.each do |gsa|
      full_name = User.find(gsa.creator_id).full_name
      gsa.first_name = full_name.split(" ").first || "Unnamed"
      gsa.last_name = full_name.split(" ").second || "Unnamed"
      gsa.save!
    end
  end
end
