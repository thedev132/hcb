# frozen_string_literal: true

class DropDescriptionFromChecks < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :checks, :description
    end
  end

end
