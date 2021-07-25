# frozen_string_literal: true

class CreateDocumentDownloads < ActiveRecord::Migration[5.2]
  def change
    create_table :document_downloads do |t|
      t.references :document, foreign_key: true
      t.references :user, foreign_key: true
      t.inet :ip_address
      t.text :user_agent

      t.timestamps
    end
  end
end
