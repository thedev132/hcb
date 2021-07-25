# frozen_string_literal: true

class AddEmburseDepartmentToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :emburse_department_id, :string
  end
end
