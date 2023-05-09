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

    include SessionsHelper
    # This endpoint is used by users (not an API endpoint)
    def login
      contract = Api::V2::LoginContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      begin
        service = AuthService::Token.new(
          token: contract[:login_token],
          ip: request.remote_ip
        )
        user = service.run

        if service.force_manual_login?
          redirect_to auth_users_url(email: user&.email || contract[:user_email]) and return
        end

        # User is eligible for ✨magic login✨

        fingerprint = {
          ip: request.remote_ip,
          # TODO: add more fingerprinting to be on par with normal login
        }

        user = sign_in(user: user, fingerprint_info: fingerprint)

        # Semi-jank way to get the session that was just created for this user
        session = user.user_sessions.last

        # Associate the new session to this login token
        service.login_token.update(user_session: session)

        # Now that they're signed in, redirect them to the dashboard (home page)
        redirect_to root_path

      rescue => e
        Airbrake.notify(e) unless e.is_a?(UnauthorizedError)
        puts e
        redirect_to auth_users_url(email: contract[:user_email])
      end
    end

    def generate_login_url
      contract = Api::V2::GenerateLoginUrlContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      event = current_partner.events.find_by_public_id(contract[:public_id])

      # Invite the user to the event
      ::EventService::PartnerInviteUser.new(
        partner: current_partner,
        event: event,
        user_email: contract[:email]
      ).run

      login_token = ApiService::V2::GenerateLoginToken.new(
        partner: current_partner,
        user_email: contract[:email],
        organization_public_id: contract[:public_id]
      ).run

      render json: Api::V2::GenerateLoginUrlSerializer.new(organization_public_id: contract[:public_id], login_token: login_token).run
    end

    def partnered_signups_new
      @partner = current_partner
      render json: json_error(contract), status: 400 and return unless @partner

      contract = Api::V2::PartneredSignupsNewContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      attrs = {
        partner_id: @partner.id,
        redirect_url: params[:redirect_url],
        organization_name: params[:organization_name],
        owner_email: params[:owner_email],
      }
      attrs[:owner_name] = params[:owner_name] if params[:owner_name]
      attrs[:owner_phone] = params[:owner_phone] if params[:owner_phone]
      attrs[:owner_address_line1] = params[:owner_address_line1] if params[:owner_address_line1]
      attrs[:owner_address_line2] = params[:owner_address_line2] if params[:owner_address_line2]
      attrs[:owner_address_city] = params[:owner_address_city] if params[:owner_address_city]
      attrs[:owner_address_state] = params[:owner_address_state] if params[:owner_address_state]
      attrs[:owner_address_postal_code] = params[:owner_address_postal_code] if params[:owner_address_postal_code]
      attrs[:owner_address_country] = params[:owner_address_country] if params[:owner_address_country]
      attrs[:owner_birthdate] = params[:owner_birthdate] if params[:owner_birthdate]

      @partnered_signup = PartneredSignup.create!(attrs)

      render json: Api::V2::PartneredSignupSerializer.new(partnered_signup: @partnered_signup).run
    end

    def partnered_signups
      contract = Api::V2::PartneredSignupsContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      partnered_signups = ::ApiService::V2::FindPartneredSignups.new(partner_id: current_partner.id).run

      render json: Api::V2::PartneredSignupsSerializer.new(partnered_signups: partnered_signups).run
    end

    def partnered_signup
      contract = Api::V2::PartneredSignupContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      partnered_signup = ::ApiService::V2::FindPartneredSignup.new(
        partner_id: current_partner.id,
        partnered_signup_public_id: contract[:public_id]
      ).run

      # if partnered_signup does not exist, throw not found error
      raise ActiveRecord::RecordNotFound and return unless partnered_signup

      render json: Api::V2::PartneredSignupSerializer.new(partnered_signup: partnered_signup).run
    end

    def donations_new
      contract = Api::V2::DonationsNewContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      partner_donation = ::ApiService::V2::DonationsNew.new(
        partner_id: current_partner.id,
        organization_public_id: contract[:organization_id]
      ).run

      render json: Api::V2::DonationsNewSerializer.new(partner_donation: partner_donation).run
    end

    def organizations
      contract = Api::V2::OrganizationsContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      organizations = ::ApiService::V2::FindOrganizations.new(partner_id: current_partner.id).run

      render json: Api::V2::OrganizationsSerializer.new(organizations: organizations).run
    end

    def organization
      contract = Api::V2::OrganizationContract.new.call(params.permit!.to_h)
      render json: json_error(contract), status: 400 and return unless contract.success?

      event = ::ApiService::V2::FindOrganization.new(
        partner_id: current_partner.id,
        organization_public_id: contract[:public_id]
      ).run

      # if event does not exist, throw not found error
      raise ActiveRecord::RecordNotFound and return unless event

      render json: Api::V2::OrganizationSerializer.new(event: event).run
    end

  end
end
