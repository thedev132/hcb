# frozen_string_literal: true

class AddShortCodeConstraintsToHcbCodes < ActiveRecord::Migration[6.0]
  def self.up
    safety_assured do
      execute "ALTER TABLE hcb_codes ADD CONSTRAINT constraint_hcb_codes_on_short_code_to_uppercase CHECK (short_code = upper(short_code))"
    end
  end

  def self.down
    safety_assured do
      execute "ALTER TABLE hcb_codes DROP CONSTRAINT constraint_hcb_codes_on_short_code_to_uppercase"
    end
  end
end
