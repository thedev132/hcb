# frozen_string_literal: true

class RemoveUniquenessFromGSuiteDomain < ActiveRecord::Migration[6.0]
  def change
    remove_index :domain, name: "index_g_suites_on_domain"
  end

end
