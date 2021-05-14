class AddPartnerToEvents < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      add_reference :events, :partner, null: true, foreign_key: true
    end
  end
end
