# frozen_string_literal: true

require 'rails_helper'

describe UsersController do
  # rubocop:disable Naming/VariableNumber
  context 'flipper flag login_code_2023_02_21' do
    context 'when flag is off' do
      it 'calls hackclub api' do
        Flipper.disable(:login_code_2023_02_21)
        expect(Partners::HackclubApi::RequestLoginCode).to receive_message_chain(:new, :run).and_return({})

        params = {
          email: "test@example.com"
        }

        post :login_code, params: params
      end
    end

    context 'when flag is on' do
      before do
        Flipper.enable(:login_code_2023_02_21)
      end

      context 'when not sent by sms' do
        it 'calls LoginCodeService::Request service in bank' do
          expect(LoginCodeService::Request).to receive_message_chain(:new, :run).and_return({})

          params = {
            email: "test@example.com"
          }

          post :login_code, params: params
        end
      end

      context 'when sent by sms' do
        it 'calls LoginCodeService::Request service in bank (which in turns calls twilio)' do
          expect(LoginCodeService::Request).to receive_message_chain(:new).and_call_original
          expect(TwilioVerificationService).to receive_message_chain(:new, :send_verification_request)

          user = create(:user, phone_number: '+18005555555')
          # need to update after the fact because of User callback on_phone_number_update resetting this value
          user.update(use_sms_auth: true)
          params = {
            email: user.email
          }

          post :login_code, params: params
        end
      end
    end
  end
  # rubocop:enable Naming/VariableNumber
end
