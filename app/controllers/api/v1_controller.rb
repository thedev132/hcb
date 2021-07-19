# frozen_string_literal: true

module Api
  class V1Controller < Api::ApplicationController
    skip_before_action :authenticate, only: [:connect_continue, :connect_finish, :login]

    def hide_footer
      @hide_footer = true
    end

    def index
      contract = Api::V1::IndexContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      render json: Api::V1::IndexSerializer.new.run
    end

    def login
      contract = Api::V1::LoginContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      attrs = {
        token: contract[:loginToken]
      }
      user = AuthService::Token.new(attrs)

      sign_in_and_set_cookie!(user)

      redirect_to root_path
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
      @partner = @event.partner

      hide_footer

      render layout: "application"
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

      attrs = {
        partner_id: current_partner.id,
        organization_identifier: contract[:organizationIdentifier]
      }
      partner_donation = ::ApiService::V1::DonationsStart.new(attrs).run

      render json: Api::V1::DonationsStartSerializer.new(partner_donation: partner_donation).run
    end

    def organizations
      contract = Api::V1::OrganizationsContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      attrs = {
        partner_id: current_partner.id,
      }
      organizations = ::ApiService::V1::Organizations.new(attrs).run

      render json: Api::V1::OrganizationsSerializer.new(organizations: organizations).run
    end

    def organization
      contract = Api::V1::OrganizationContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      attrs = {
        partner_id: current_partner.id,
        organization_identifier: contract[:organizationIdentifier]
      }
      event = ::ApiService::V1::Organization.new(attrs).run

      # if event does not exist, throw not found error
      raise ActiveRecord::RecordNotFound and return unless event

      render json: Api::V1::OrganizationSerializer.new(event: event).run
    end
  end
end
