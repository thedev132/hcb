# frozen_string_literal: true

class RemovePartnerLogoUrlFromEvents < ActiveRecord::Migration[6.0]
  def change
    safety_assured { remove_column :events, :partner_logo_url }
  end
end
