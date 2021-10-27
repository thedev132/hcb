class AddWebhookUrlToPartners < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :webhook_url, :string
  end
end
