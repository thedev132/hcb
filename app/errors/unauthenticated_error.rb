# frozen_string_literal: true

class UnauthenticatedError < ArgumentError
  def initialize(msg = "Unauthenticated")
    super
  end

  def status
    401
  end
end
