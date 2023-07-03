# frozen_string_literal: true

class EventDoesNotRequireAPartner < ActiveRecord::Migration[7.0]
  def change
    change_column_null :events, :partner_id, true
  end

end
