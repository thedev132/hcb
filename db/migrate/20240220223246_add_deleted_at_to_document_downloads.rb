class AddDeletedAtToDocumentDownloads < ActiveRecord::Migration[7.0]
  def change
    add_column :document_downloads, :deleted_at, :timestamp
  end
end
