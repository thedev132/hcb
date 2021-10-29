# frozen_string_literal: true

class AddSubmittedAtToPartneredSignups < ActiveRecord::Migration[6.0]
  def change
    add_column :partnered_signups, :submitted_at, :timestamp
  end
end
