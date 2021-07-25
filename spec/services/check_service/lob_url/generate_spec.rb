# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckService::LobUrl::Generate, type: :model do
  fixtures  "checks"

  let(:check) { checks(:check1) }

  let(:attrs) do
    {
      check: check,
    }
  end

  let(:service) { CheckService::LobUrl::Generate.new(attrs) }

  let(:url) { "http://lob.com/some/url" }
  let(:resp) { { "url" => url } }

  before do
    allow(service).to receive(:remote_check).and_return(resp)
  end

  it "returns a url" do
    result = service.run

    expect(result).to eql(url)
  end
end
