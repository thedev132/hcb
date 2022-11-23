# frozen_string_literal: true

class AddStepToTour < ActiveRecord::Migration[6.1]
  def change
    add_column :tours, :step, :integer, default: 0
  end

end
