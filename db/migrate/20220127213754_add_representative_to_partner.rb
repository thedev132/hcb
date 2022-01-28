# frozen_string_literal: true

class AddRepresentativeToPartner < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_reference :partners,
                    :representative,
                    foreign_key: { to_table: :users },
                    index: { algorithm: :concurrently }
    end
  end

end
