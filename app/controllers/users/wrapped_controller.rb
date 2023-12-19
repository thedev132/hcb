# frozen_string_literal: true

module Users
  class WrappedController < ApplicationController
    skip_after_action :verify_authorized
    before_action :set_data

    def index
      unless Flipper.enabled?(:bank_wrapped, current_user)
        render plain: "HCB Wrapped coming soon! I heard #{current_user&.first_name.presence&.concat("'s") || "you're"} on the naughty list 🎅" and return
      end

      ahoy.track "Wrapped 2023 viewed", user_id: current_user.id

      render layout: "bare"
    end

    def data
      headers["Content-Disposition"] = "attachment; filename=wrapped.json"

      render json: @data
    end

    private

    def set_data
      @data = {
        individual: {
          name: current_user.full_name,
          firstName: current_user.first_name,
          id: current_user.id,
          totalMoneySpent: Metric::User::TotalSpent.from(current_user).metric,
          spendingByDate: Metric::User::SpendingByDate.from(current_user).metric,
          ranking: Metric::Hcb::SpendingByUser.metric.keys.index(current_user.id).to_f / Metric::Hcb::SpendingByUser.metric.keys.size, # this still needs to be done, we have spending by user
          averageReceiptUploadTime: Metric::User::TimeToReceipt.from(current_user).metric, # in seconds
          lostReceiptCount: Metric::User::LostReceiptCount.from(current_user).metric,
          platinumCard: Metric::User::PlatinumCard.from(current_user).metric,
          words: Metric::User::Words.from(current_user).metric.first(20).to_h.keys, # needs a format change to an array (rn it's a has)
          spendingByLocation: Metric::User::SpendingByLocation.from(current_user).metric, # needs a format change on the React-side, should match spendingByCat format
          spendingByCategory: Metric::User::SpendingByCategory.from(current_user).metric,
          spendingByMerchant: Metric::User::SpendingByMerchant.from(current_user).metric,
        },
        organizations: current_user.events.map do |event|
          [event.name, {
            spendingByUser: Metric::Event::SpendingByUser.from(event).metric,
            category: event.category,
            spent: Metric::Event::TotalSpent.from(event).metric,
            raised: Metric::Event::TotalRaised.from(event).metric,
            spendingByDate: Metric::Event::SpendingByDate.from(event).metric,
            spendingByLocation: Metric::Event::SpendingByLocation.from(event).metric,
            spendingByCategory: Metric::Event::SpendingByCategory.from(event).metric,
            spendingByMerchant: Metric::Event::SpendingByMerchant.from(event).metric,
          }]
        end.to_h,
        hcb: {
          raised: Metric::Hcb::TotalRaised.metric,
          spent: Metric::Hcb::TotalSpent.metric,
          organizations: {
            total: Metric::Hcb::TotalEvents.metric,
            new: Metric::Hcb::NewEvents.metric,
          },
          users: {
            total: Metric::Hcb::TotalUsers.metric,
            new: Metric::Hcb::NewUsers.metric,
          },
          spendingByLocation: Metric::Hcb::SpendingByLocation.metric,
          spendingByCategory: Metric::Hcb::SpendingByCategory.metric,
          spendingByMerchant: Metric::Hcb::SpendingByMerchant.metric,
          spendingByDate: Metric::Hcb::SpendingByDate.metric,
        },
      }
    end

  end
end
