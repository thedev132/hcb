# frozen_string_literal: true

class CreateOrganizerPositionDeletionRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :organizer_position_deletion_requests do |t|
      t.references :organizer_position, foreign_key: true, index: { name: :index_organizer_deletion_requests_on_organizer_position_id }
      t.references :submitted_by, foreign_key: { to_table: :users }
      t.references :closed_by, foreign_key: { to_table: :users }
      t.timestamp :closed_at
      t.text :reason
      t.boolean :subject_has_outstanding_expenses_expensify, null: false, default: false
      t.boolean :subject_has_outstanding_transactions_emburse, null: false, default: false
      t.boolean :subject_emails_should_be_forwarded, null: false, default: false

      t.timestamps
    end
  end
end
