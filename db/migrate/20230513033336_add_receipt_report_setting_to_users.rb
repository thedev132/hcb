# frozen_string_literal: true

class AddReceiptReportSettingToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :receipt_report_option, :integer, default: 0, null: false
  end

end
