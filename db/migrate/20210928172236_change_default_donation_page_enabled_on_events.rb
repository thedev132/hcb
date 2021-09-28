class ChangeDefaultDonationPageEnabledOnEvents < ActiveRecord::Migration[6.0]
  def up
    change_column_default(:events, :donation_page_enabled, true)
  end

  def down
    change_column_default(:events, :donation_page_enabled, nil)
  end
end
