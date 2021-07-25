# frozen_string_literal: true

class RemoveUrlFromChecks < ActiveRecord::Migration[5.2]
  # Lob URLs expire after 30 days, so we should generate this on the fly instead of storing in the database.
  # https://lob.com/docs/ruby#urls

  def change
    remove_column :checks, :url, :string
  end
end
