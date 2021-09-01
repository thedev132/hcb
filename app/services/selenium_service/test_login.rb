# frozen_string_literal: true

module SeleniumService
  class TestLogin
    include ::Shared::Selenium::LoginToSvb

    def run
      login_to_svb!
    end
  end
end
