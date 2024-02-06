class CreateColumnStatements < ActiveRecord::Migration[7.0]
  def change
    create_table :column_statements do |t|
      t.datetime :start_date
      t.datetime :end_date
      
      t.timestamps
    end
  end
end
