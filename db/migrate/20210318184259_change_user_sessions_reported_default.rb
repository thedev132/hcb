# frozen_string_literal: true

class ChangeUserSessionsReportedDefault < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :sessions_reported, false
  end
end
