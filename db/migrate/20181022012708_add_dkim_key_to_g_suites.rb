# frozen_string_literal: true

class AddDkimKeyToGSuites < ActiveRecord::Migration[5.2]
  def change
    add_column :g_suites, :dkim_key, :text
  end
end
