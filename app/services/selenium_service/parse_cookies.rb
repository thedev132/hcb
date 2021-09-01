# frozen_string_literal: true

module SeleniumService
  class ParseCookies
    include ::Shared::Selenium::LoginToSvb

    def initialize(cookie_txt:)
      @cookie_txt = cookie_txt
    end

    def run
      cookies = {}

      CSV.new(@cookie_txt, col_sep: "\t", headers: false).each do |row|
        next unless row.length > 4

        cookies[row[-2]] = row[-1]
      end

      cookies
    end
  end
end
