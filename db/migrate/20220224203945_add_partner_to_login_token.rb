# frozen_string_literal: true

class AddPartnerToLoginToken < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_reference :login_tokens, :partner,
                  null: true,
                  index: { algorithm: :concurrently }
  end

end
