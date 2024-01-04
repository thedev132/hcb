# frozen_string_literal: true

module StripeCardholderService
  class Update
    def initialize(current_user:)
      @current_user = current_user
    end

    def run
      ActiveRecord::Base.transaction do
        stripe_cardholder = ::StripeCardholder.find_by(user_id: @current_user.id)
        ::StripeService::Issuing::Cardholder.update(stripe_cardholder.stripe_id, remote_params) unless stripe_cardholder.nil?
      end
    end

    private

    def remote_params
      { individual: { dob: DateOfBirthAgeRestrictedExtractor.new(user: @current_user).run } }
    end

  end
end
