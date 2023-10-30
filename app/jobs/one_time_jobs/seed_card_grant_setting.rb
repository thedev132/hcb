# frozen_string_literal: true

module OneTimeJobs
  class SeedCardGrantSetting < ApplicationJob
    def perform
      onboard = Event.find_by_slug("onboard")
      process_event onboard unless onboard.card_grant_setting.present?
      onboard.card_grant_setting.invite_message = <<~MD
        Welcome aboard!#{' '}

        1. Accept your grant on HCB & issue a virtual card. Keep in mind this card should only be used to purchase the design you subitted to the repo.
        2. Order your board on JLC (or other vendor)!
        3. Once your board arrives, test it out and post about it in #onboard– if it works you can show it off and if something is broken people in there can help you fix it.
      MD
      onboard.card_grant_setting.save!

      pizza_party = Event.find_by_slug("2023-pizza-grant")
      process_event pizza_party unless pizza_party.card_grant_setting.present?
      pizza_party.card_grant_setting.invite_message = <<~MD
        _It's pizza time!_
      MD
      pizza_party.card_grant_setting.save!
    end

    private

    def process_event(event)
      cgs = CardGrantSetting.new
      cgs.event = event
      example_grant = event.card_grants.last
      cgs.merchant_lock = example_grant.merchant_lock
      cgs.category_lock = example_grant.category_lock
      cgs.save!
    end

  end
end
