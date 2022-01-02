# frozen_string_literal: true

class AddOutstandingCardsToOrganizerPositionDeletionRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :organizer_position_deletion_requests, :subject_has_outstanding_transactions_stripe, :boolean, null: false, default: false
    add_column :organizer_position_deletion_requests, :subject_has_active_cards, :boolean, null: false, default: false
  end
end
