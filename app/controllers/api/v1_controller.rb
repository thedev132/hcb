# frozen_string_literal: true

module Api
  class V1Controller < Api::ApplicationController
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
  end
end
