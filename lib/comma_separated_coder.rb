# frozen_string_literal: true

class CommaSeparatedCoder
  def self.load(value)
    value&.split(/,\s*/) || []
  end

  def self.dump(value)
    if value.is_a?(Array)
      value.join(",")
    elsif value.is_a?(String)
      value
    end
  end

end
