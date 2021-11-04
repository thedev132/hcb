# frozen_string_literal: true

module Api
  class V2Controller < Api::ApplicationController
    skip_before_action :authenticate, only: [:login]

    def hide_footer
      @hide_footer = true
    end

    def index
      contract = Api::V2::IndexContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      render json: Api::V2::IndexSerializer.new.run
    end

    def login
      contract = Api::V2::LoginContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      attrs = {
        token: contract[:login_token]
      }
      user = AuthService::Token.new(attrs).run

      sign_in_and_set_cookie!(user)

      redirect_to root_path
    end

    def generate_login_url
      contract = Api::V2::GenerateLoginUrlContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      event = current_partner.events.find_by_public_id(contract[:public_id])
      current_partner.add_user_to_partnered_event!(user_email: contract[:email], event: event)

      attrs = {
        email: contract[:email],
        organization_public_id: contract[:public_id]
      }

      render json: Api::V2::GenerateLoginUrlSerializer.new(attrs).run
    end

    def partnered_signups_new
      @partner = current_partner
      render json: json_error(contract), status: 400 and return unless @partner

      contract = Api::V2::PartneredSignupsNewContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      @partnered_signup = PartneredSignup.create!(partner_id: @partner.id,
                                                  redirect_url: params[:redirect_url],
                                                  organization_name: params[:organization_name],
                                                )

      render json: Api::V2::PartneredSignupSerializer.new(partnered_signup: @partnered_signup).run
    end

    def partnered_signups
      contract = Api::V2::PartneredSignupsContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      attrs = {
        partner_id: current_partner.id,
      }
      partnered_signups = ::ApiService::V2::FindPartneredSignups.new(attrs).run

      render json: Api::V2::PartneredSignupsSerializer.new(partnered_signups: partnered_signups).run
    end

    def partnered_signup
      contract = Api::V2::PartneredSignupContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      attrs = {
        partner_id: current_partner.id,
        partnered_signup_public_id: contract[:public_id]
      }
      partnered_signup = ::ApiService::V2::FindPartneredSignup.new(attrs).run

      # if partnered_signup does not exist, throw not found error
      raise ActiveRecord::RecordNotFound and return unless partnered_signup

      render json: Api::V2::PartneredSignupSerializer.new(partnered_signup: partnered_signup).run
    end

    def donations_new
      contract = Api::V2::DonationsNewContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      attrs = {
        partner_id: current_partner.id,
        organization_public_id: contract[:organization_id]
      }
      partner_donation = ::ApiService::V2::DonationsNew.new(attrs).run

      render json: Api::V2::DonationsNewSerializer.new(partner_donation: partner_donation).run
    end

    def organizations
      contract = Api::V2::OrganizationsContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      attrs = {
        partner_id: current_partner.id,
      }
      organizations = ::ApiService::V2::FindOrganizations.new(attrs).run

      render json: Api::V2::OrganizationsSerializer.new(organizations: organizations).run
    end

    def organization
      contract = Api::V2::OrganizationContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      attrs = {
        partner_id: current_partner.id,
        organization_public_id: contract[:public_id]
      }
      event = ::ApiService::V2::FindOrganization.new(attrs).run

      # if event does not exist, throw not found error
      raise ActiveRecord::RecordNotFound and return unless event

      render json: Api::V2::OrganizationSerializer.new(event: event).run
    end
  end
end
