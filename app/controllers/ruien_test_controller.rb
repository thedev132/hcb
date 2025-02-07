# frozen_string_literal: true

class RuienTestController < ApplicationController
  skip_after_action :verify_authorized, only: :show

  def show
    # This route exists to determine whether Rails reporter will capture context
    # on the request (e.g. route, controller, action, params, user, etc.)
    Rails.error.handle do
      raise StandardError.new("Ruien test: inside handle")
    end

    begin
      raise StandardError.new("Ruien test: rescued with report")
    rescue => e
      Rails.error.report(e)
    end
  end

end
