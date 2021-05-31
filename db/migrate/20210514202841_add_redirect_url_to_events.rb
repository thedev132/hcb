class AddRedirectUrlToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :redirect_url, :string
  end
end
