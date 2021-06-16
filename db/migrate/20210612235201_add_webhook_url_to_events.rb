class AddWebhookUrlToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :webhook_url, :string
  end
end
