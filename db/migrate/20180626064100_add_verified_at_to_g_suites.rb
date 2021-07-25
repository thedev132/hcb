# frozen_string_literal: true

class AddVerifiedAtToGSuites < ActiveRecord::Migration[5.2]
  def change
    add_column :g_suites, :verified_at, :timestamp
  end
end
