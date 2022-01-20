# frozen_string_literal: true

class AddImpersonatedByToUserSessions < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_reference :user_sessions,
                    :impersonated_by,
                    foreign_key: { to_table: :users },
                    index: { algorithm: :concurrently }
    end
  end

end
