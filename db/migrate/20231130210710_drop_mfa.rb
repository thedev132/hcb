# frozen_string_literal: true

class DropMfa < ActiveRecord::Migration[7.0]
  def change
    drop_table :mfa_codes, force: :cascade
    drop_table :mfa_requests, force: :cascade
  end

end
