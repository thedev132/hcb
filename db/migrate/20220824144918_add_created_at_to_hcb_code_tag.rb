# frozen_string_literal: true

class AddCreatedAtToHcbCodeTag < ActiveRecord::Migration[6.1]
  def change
    safety_assured {
      change_table :hcb_codes_tags do |t|
        t.timestamps null: true
      end
    }
  end

end
