class ChangeAFewNullColumnsToNotNull < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      change_column_null :events, :organization_identifier, false
      change_column_null :events, :partner_id, false
    end
  end
end
