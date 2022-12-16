# frozen_string_literal: true

class ChangeDefaultValueforIsPublicOnEvents < ActiveRecord::Migration[6.1]
  def change
    change_column_default :events, :is_public, true
  end

end
