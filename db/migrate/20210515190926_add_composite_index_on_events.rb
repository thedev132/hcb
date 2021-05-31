class AddCompositeIndexOnEvents < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      add_index :events, [:partner_id, :organization_identifier], unique: true
    end
  end
end
