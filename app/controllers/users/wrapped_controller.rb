# frozen_string_literal: true

module Users
  class WrappedController < ApplicationController
    skip_after_action :verify_authorized

    def index
    end

    def data
      @data = {
        individual: {
          firstName: current_user.full_name,
          totalMoneySpent: Metric::User::TotalSpent.from(current_user).metric,
          spendingByDate: Metric::User::SpendingByDate.from(current_user).metric,
          ranking: Metric::Hcb::SpendingByUser.metric.to_h.keys.index(current_user.id).to_f / Metric::Hcb::SpendingByUser.metric.to_h.keys.size, # this still needs to be done, we have spending by user
          averageReceiptUploadTime: Metric::User::TimeToReceipt.from(current_user).metric, # in seconds
          lostReceiptCount: Metric::User::LostReceiptCount.from(current_user).metric,
          platinumCard: Metric::User::PlatinumCard.from(current_user).metric,
          words: Metric::User::Words.from(current_user).metric.select { |key, value| key.length >= 3 }.sort_by { |_, value| -value }.first(20).to_h.keys, # needs a format change to an array (rn it's a has)
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
      headers["Content-Type"] = "application/json"
      headers["Content-disposition"] = "attachment; filename=wrapped.json"
      set_streaming_headers

      response.status = 200

      self.response_body = @data.to_json
    end

  end
end
