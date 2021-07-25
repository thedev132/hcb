# frozen_string_literal: true

class AddLobUrlToChecks < ActiveRecord::Migration[6.0]
  def change
    add_column :checks, :lob_url, :text
  end
end
