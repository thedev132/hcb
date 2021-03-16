module DonationService
  class Nightly
    def run
      ::DonationService::Import.new.run
    end
  end
end
