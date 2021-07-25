# frozen_string_literal: true

class AddUniqueIndexToDomainForGSuites < ActiveRecord::Migration[6.0]
  def up
    enable_extension("citext")

    safety_assured do
      change_column :g_suites, :domain, :citext
      add_index :g_suites, :domain, unique: true
    end
  end

  def down
    safety_assured do
      remove_index :g_suites, :domain
      change_column :g_suites, :domain, :string
    end
  end
end
