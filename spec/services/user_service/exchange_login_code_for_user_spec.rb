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
      auth_token: auth_token
    }
  end

  let(:exchange_login_code_error_resp) do
    {
      errors: ["error"]
    }
  end

  let(:get_user_resp) do
    {
      email: user.email,
      admin_at: user.admin_at
    }
  end

  context 'when exchange_login_code_resp and get_user_resp return expected values from hackclub/api' do
    before do
      allow(service).to receive(:exchange_login_code_resp).and_return(exchange_login_code_resp)
      allow(service).to receive(:get_user_resp).and_return(get_user_resp)
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

  # rubocop:disable Naming/VariableNumber
  context 'flipper flag login_code_2023_02_21' do
    let(:login_code) { create(:login_code) }
    let(:user) { login_code.user }
    let(:service) { UserService::ExchangeLoginCodeForUser.new(user_id: user.id, login_code: login_code.code) }

    context 'when flag is off' do
      it 'calls hackclub api' do
        Flipper.disable(:login_code_2023_02_21)
        expect(Partners::HackclubApi::ExchangeLoginCode).to receive_message_chain(:new, :run)
          .and_return({})
        expect(Partners::HackclubApi::GetUser).to receive_message_chain(:new, :run)
          .and_return({ email: user.email })

        service.run
      end
    end

    context 'when flag is on' do
      let(:service) {
        UserService::ExchangeLoginCodeForUser.new(
          user_id: user.id,
          login_code: login_code.code,
          sms: sms
        )
      }

      before do
        Flipper.enable(:login_code_2023_02_21)
      end

      context 'when not sent by sms' do
        let(:sms) { false }

        it 'exchanges login code for user in bank' do
          exchanged_user = service.run
          expect(exchanged_user).to eq(user)
        end
      end

      context 'when sent by sms' do
        let(:sms) { true }

        it 'calls hackclub api' do
          expect(Partners::HackclubApi::ExchangeLoginCode).to receive_message_chain(:new, :run)
            .and_return({})
          expect(Partners::HackclubApi::GetUser).to receive_message_chain(:new, :run)
            .and_return({ email: user.email })

          service.run
        end
      end
    end
  end
  # rubocop:enable Naming/VariableNumber
end
