# frozen_string_literal: true

class RenameCardsToEmburseCards < ActiveRecord::Migration[6.0]
  def change
    rename_table :cards, :emburse_cards

    rename_column :load_card_requests, :card_id, :emburse_card_id
    rename_column :card_requests, :card_id, :emburse_card_id

    # (msw) Now that we're renaming card -> emburse_card, rails association
    # helpers need to use 'emburse_card_id' as a foreign key

    # we're renaming 'emburse_card_id' (used while matching transactions to
    # cards + events) to 'emburse_card_uuid' to free up the namespace
    rename_column :emburse_transactions, :emburse_card_id, :emburse_card_uuid
    rename_column :emburse_transactions, :card_id, :emburse_card_id
  end
end
