class CreateMfaCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :mfa_codes do |t|
      t.text :message
      t.string :code
      t.string :provider

      t.timestamps
    end
  end
end
