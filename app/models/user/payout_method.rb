# frozen_string_literal: true

class User
  module PayoutMethod
    def kind
      "unknown"
    end

    def icon
      "docs"
    end

    def name
      "an unknown method"
    end

  end

end
