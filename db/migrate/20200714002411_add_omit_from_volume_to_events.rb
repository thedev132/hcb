class AddOmitFromVolumeToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :omit_from_volume, :boolean, default: false
  end
end
