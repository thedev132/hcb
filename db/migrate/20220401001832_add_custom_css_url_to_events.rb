# frozen_string_literal: true

class AddCustomCssUrlToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :custom_css_url, :string
  end

end
