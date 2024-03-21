# frozen_string_literal: true

module OneTimeJobs
  class BackfillPostalCodes
    def self.perform
      # rubocop:disable Rails/FindEach
      ApplicationsTable.all.each do |application|
        next unless application["Zip Code"] && application["HCB Slug"]

        slug = application["HCB Slug"]
        event = Event.friendly.find(slug) rescue nil
        next unless event

        event.update(postal_code: application["Zip Code"])
        puts event.name
      end
      # rubocop:enable Rails/FindEach
    end

  end
end
