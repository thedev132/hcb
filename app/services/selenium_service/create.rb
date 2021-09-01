# frozen_string_literal: true

module SeleniumService
  class Create
    def initialize(file:)
      @file = file
    end

    def run
      ::SeleniumSession.create!(attrs)
    end

    private

    def attrs
      {
        cookies: cookies
      }
    end

    def cookies
      ::SeleniumService::ParseCookies.new(cookie_txt: cookie_txt).run
    end

    def cookie_txt
      @cookie_txt ||= @file.read
    end
  end
end
