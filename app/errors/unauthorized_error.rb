# frozen_string_literal: true

class UnauthorizedError < ArgumentError
  def initialize(msg = "Unauthorized")
    super
  end

  def status
    403
  end
end
