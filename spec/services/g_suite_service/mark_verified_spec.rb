# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GSuiteService::MarkVerified, type: :model do
  fixtures  'users', 'g_suites'
  
  let(:g_suite) { g_suites(:g_suite2) }

  let(:attrs) do
    {
      g_suite_id: g_suite.id
    }
  end

  let(:service) { GSuiteService::MarkVerified.new(attrs) }

  before do
    allow(service).to receive(:verified_on_google?).and_return(true)
  end

  it 'changes state' do
    expect(g_suite).not_to be_verified

    service.run

    expect(g_suite.reload).to be_verified
  end

  it 'does not send an email' do
    service.run

    mail = ActionMailer::Base.deliveries.last

    expect(mail).to eql(nil)
  end

  context 'when created by exists' do
    let(:user) { users(:user1) }

    before do
      g_suite.created_by = user
      g_suite.save!
    end

    it 'sends an email' do
      service.run

      mail = ActionMailer::Base.deliveries.last

      expect(mail.to).to eql([user.email])
      expect(mail.subject).to include('event2.example.com')
    end

    context 'when verified_on_google is false' do
      before do
        allow(service).to receive(:verified_on_google?).and_return(false)
      end

      it 'does not send an email' do
        service.run

        mail = ActionMailer::Base.deliveries.last

        expect(mail).to eql(nil)
      end

      it 'does not change state' do
        expect(g_suite).not_to be_verified

        service.run

        expect(g_suite.reload).not_to be_verified
      end
    end
  end

  context 'when verified is false' do
    before do
      allow(service).to receive(:verified_on_google?).and_return(false)
    end

    it 'does not change state' do
      service.run

      expect(g_suite.reload).to_not be_verified
    end

    it 'does not send a mailer' do
      service.run
    end
  end

  context 'when network or other error occurs' do
    before do
      allow(service).to receive(:verified_on_google?).and_raise(ArgumentError)
    end

    it 'does not change state' do
      expect do
        service.run
      end.to raise_error(ArgumentError)

      expect(g_suite.reload).to_not be_verified
    end
  end
end
