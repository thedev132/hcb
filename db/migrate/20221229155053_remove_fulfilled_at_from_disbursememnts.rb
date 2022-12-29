# frozen_string_literal: true

class RemoveFulfilledAtFromDisbursememnts < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :disbursements, :fulfilled_at, :datetime }
  end

end
