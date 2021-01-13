class AddDefaultTransactionEngineV2AtTimestamp < ActiveRecord::Migration[6.0]
  def up
    safety_assured do
      execute "ALTER TABLE events ALTER COLUMN transaction_engine_v2_at SET DEFAULT CURRENT_TIMESTAMP;"
    end
  end

  def down
    safety_assured do
      execute "ALTER TABLE events ALTER COLUMN transaction_engine_v2_at DROP DEFAULT;"
    end
  end
end
