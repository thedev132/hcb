# frozen_string_literal: true

class InvalidateSessions < ActiveRecord::Migration[5.2]
  class User < ActiveRecord::Base; end

  def change
    User.update_all(session_token: nil)
  end
end
