# frozen_string_literal: true

require "rails_helper"

RSpec.describe SeleniumService::ParseCookies, type: :model do
  let(:file) { file_fixture("svbconnect.com_cookies.txt") }
  let(:cookie_txt) { file.read }

  let(:attrs) do
    {
      cookie_txt: cookie_txt
    }
  end

  let(:service) { SeleniumService::ParseCookies.new(attrs) }

  it "parses" do
    result = service.run

    expect(result["OnlineSiliconDummy"]).to eql("gkmZEhT0v7cwmoVnWHiDcKrkpa6MtGhZB75exilCxbktz0Q0crkN!-2059753470")
  end
end
