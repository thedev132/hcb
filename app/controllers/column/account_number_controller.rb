# frozen_string_literal: true

module Column
  class AccountNumberController < ApplicationController
    include SetEvent
    before_action :set_event

    def create
      if @event.column_account_number.nil?
        column_account_number = authorize @event.build_column_account_number
        column_account_number.save!
      else
        skip_authorization
      end
      redirect_to account_number_event_path(@event)

    rescue Faraday::Error => e
      notify_airbrake(e)
      redirect_to account_number_event_path(@event), flash: { error: "Something went wrong: #{JSON.parse(e.response_body)["message"]}" }

    end

  end
end
