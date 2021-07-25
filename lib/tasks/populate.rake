# frozen_string_literal: true

namespace :populate do
  desc "add development data to the database"
  task development: :environment do
    raise ArgumentError, "DEVELOPMENT ONLY!" unless Rails.env.development?

    PopulateService::Development::Generate.new.run

  end
end
