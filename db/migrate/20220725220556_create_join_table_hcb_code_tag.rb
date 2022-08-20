# frozen_string_literal: true

class CreateJoinTableHcbCodeTag < ActiveRecord::Migration[6.1]
  def change
    create_join_table :hcb_codes, :tags
  end

end
