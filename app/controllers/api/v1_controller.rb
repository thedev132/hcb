# frozen_string_literal: true

module Api
  class V1Controller < Api::ApplicationController
    skip_before_action :authenticate, only: [:connect_continue, :connect_finish]

    def index
      contract = Api::V1::IndexContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      render json: Api::V1::IndexSerializer.new.run
    end

    def connect_start
      contract = Api::V1::ConnectStartContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      attrs = {
        partner_id: current_partner.id,
        organization_identifier: contract[:organizationIdentifier],
        redirect_url: contract[:redirectUrl],
        webhook_url: contract[:webhookUrl]
      }
      event = ::ApiService::V1::ConnectStart.new(attrs).run

      render json: Api::V1::ConnectStartSerializer.new(event: event).run
    end

    def connect_continue
      contract = Api::V1::ConnectContinueContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      @event = Event.find(params[:hashid])
    end

    def connect_finish
      contract = Api::V1::ConnectFinishContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      attrs = {
        event_id: contract[:hashid],
        organization_name: contract[:organization_name],
        organization_url: contract[:organization_url],
        name: contract[:name],
        email: contract[:email],
        phone: contract[:phone],
        address: contract[:address],
        birthdate: contract[:birthdate]
      }
      event = ::ApiService::V1::ConnectFinish.new(attrs).run

      redirect_to "#{event.redirect_url}?organizationIdentifier=#{event.organization_identifier}&status=#{event.aasm_state}"
    end

    def donations_start
      contract = Api::V1::DonationsStartContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?
    end
  end
end
