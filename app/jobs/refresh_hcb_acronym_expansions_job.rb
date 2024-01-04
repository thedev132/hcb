# frozen_string_literal: true

class RefreshHcbAcronymExpansionsJob < ApplicationJob
  queue_as :low
  def perform
    response = Faraday.get("https://raw.githubusercontent.com/hackclub/hcb-expansions/main/phrases.txt")

    if response.success?
      hcb_acronym_expansions = response.body.split("\n")

      Rails.cache.write "hcb_acronym_expansions", hcb_acronym_expansions
    end
  end

end
