# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GSuiteAccountService::Create, type: :model do
  fixtures  'users', 'events',  'g_suites'
  
  let(:g_suite) { g_suites(:g_suite1) }
  let(:current_user) { users(:user1) }

  let(:backup_email) { 'backup@mailinator.com' }
  let(:address) { 'address' }
  let(:first_name) { 'First' }
  let(:last_name) { 'Last' }

  let(:remote_org_unit) do
    double('remoteOrgUnit', name: g_suite.ou_name, org_unit_id: 'id:1234', org_unit_path: "/Events/#{g_suite.ou_name}")
  end

  let(:attrs) do
    {
      g_suite: g_suite,
      current_user: current_user,

      backup_email: backup_email,
      address: address,
      first_name: first_name,
      last_name: last_name
    }
  end

  let(:service) { GSuiteAccountService::Create.new(attrs) }

  before do
    allow_any_instance_of(::Partners::Google::GSuite::OrgUnit).to receive(:run).and_return(remote_org_unit)
    allow_any_instance_of(::Partners::Google::GSuite::CreateUser).to receive(:run).and_return(remote_org_unit)
  end

  it 'creates g suite account' do
    expect do
      service.run
    end.to change(GSuiteAccount, :count).by(1)
  end

  it 'sends 1 mailer' do
    g_suite_account = service.run

    mail = ActionMailer::Base.deliveries.last

    expect(mail.to).to eql(['backup@mailinator.com'])
    expect(mail.subject).to include('Your Google Workspace account via Bank is ready')
    expect(mail.body).to include('address@event1.example.com')
    expect(mail.body).to include(g_suite_account.initial_password)
  end

  context 'when remote org unit does not exist' do
    before do
      allow_any_instance_of(::Partners::Google::GSuite::OrgUnit).to receive(:run).and_return(nil)
      allow_any_instance_of(::Partners::Google::GSuite::CreateOrgUnit).to receive(:run).and_return(remote_org_unit)
    end

    it 'creates the remote org unit and creates the g suite account' do
      expect do
        service.run
      end.to change(GSuiteAccount, :count).by(1)
    end

    it 'assigns remote_org_unit_id' do
      expect do
        service.run
      end.to change(g_suite.reload, :remote_org_unit_id).to('id:1234')
    end
    
    it 'assigns remote_org_unit_path' do
      expect do
        service.run
      end.to change(g_suite.reload, :remote_org_unit_path).to("/Events/#{g_suite.ou_name}")
    end
  end

  context 'when remote create user fails' do
    before do
      allow_any_instance_of(::Partners::Google::GSuite::CreateUser).to receive(:run).and_raise(ArgumentError)
    end

    it 'does not create g suite account' do
      expect do
        service.run rescue nil
      end.not_to change(GSuiteAccount, :count)
    end

    it 'raises an errro' do
      expect do
        service.run
      end.to raise_error(ArgumentError)
    end
  end

  describe 'private' do
    describe '#full_email_address' do
      it 'builds' do
        result = service.send(:full_email_address)

        expect(result).to eql('address@event1.example.com')
      end
    end
  end
end
