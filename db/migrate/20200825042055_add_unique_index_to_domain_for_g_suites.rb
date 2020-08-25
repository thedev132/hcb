class AddUniqueIndexToDomainForGSuites < ActiveRecord::Migration[6.0]
  def change
    enable_extension("citext")

    safety_assured do
      change_column :g_suites, :domain, :citext
      add_index :g_suites, :domain, unique: true
    end
  end
end
