# frozen_string_literal: true

class DropContentFromComments < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :comments, :content
    end
  end

end
