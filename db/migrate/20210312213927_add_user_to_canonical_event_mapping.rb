class AddUserToCanonicalEventMapping < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_reference :canonical_event_mappings, :user, index: {algorithm: :concurrently}
  end
end
