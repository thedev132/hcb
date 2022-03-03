# frozen_string_literal: true

class AddUserSessionToLoginToken < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_reference :login_tokens, :user_session,
                    null: true, foreign_key: true,
                    index: { algorithm: :concurrently }
    end
  end

end
