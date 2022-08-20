# frozen_string_literal: true

class RemoveTagIdFromHcbCodes < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :hcb_codes, :tag_id }
  end

end
