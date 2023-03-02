# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserService::ExchangeLoginCodeForUser, type: :model do
  let(:user) { create(:user) }

  let(:user_id) { 1234 }
  let(:login_code) { "555-555" }

  let(:auth_token) { "abcd" }

  let(:attrs) do
    {
      user_id: user_id,
      login_code: login_code
    }
  end

  let(:service) { UserService::ExchangeLoginCodeForUser.new(attrs) }

  let(:exchange_login_code_resp) do
    {
      user: user,
      auth_token: auth_token
    }
  end

  let(:exchange_login_code_error_resp) do
    {
      errors: ["error"]
    }
  end

  context 'when exchange_login_code_resp and get_user_resp return expected values from hackclub/api' do
    before do
      allow(service).to receive(:exchange_login_code_resp).and_return(exchange_login_code_resp)
    end

    it "returns the user" do
      user = service.run

      expect(user.id).to eql(user.id)
    end
  end

  context "when login code response has errors" do
    before do
      allow(service).to receive(:exchange_login_code_resp).and_return(exchange_login_code_error_resp)
    end

    it "raises error" do
      expect do
        service.run
      end.to raise_error(::Errors::InvalidLoginCode)
    end
  end

  context 'sms' do
    let(:login_code) { create(:login_code) }
    let(:user) { login_code.user }
    let(:service) {
      UserService::ExchangeLoginCodeForUser.new(
        user_id: user.id,
        login_code: login_code.code,
        sms: sms
      )
    }

    context 'when not sent by sms' do
      let(:sms) { false }

      it 'exchanges login code for user in bank' do
        exchanged_user = service.run
        expect(exchanged_user).to eq(user)
      end
    end

    context 'when sent by sms' do
      let(:sms) { true }

      it 'calls twilio' do
        expect(TwilioVerificationService).to receive_message_chain(:new, :check_verification_token).and_return(true)

        exchanged_user = service.run
        expect(exchanged_user).to eq(user)
      end
    end
  end
end
