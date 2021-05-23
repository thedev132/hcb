# frozen_string_literal: true

class NotFoundError < StandardError
  def initialize(msg = "Not found")
    super
  end

  def status
    404
  end
end
