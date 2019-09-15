class AddEventPartnerLogo < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :partner_logo_url, :text
  end
end
