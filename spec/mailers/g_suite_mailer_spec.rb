# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GSuiteMailer, type: :mailer do
  fixtures  'g_suites'
  
  let(:g_suite) { g_suites(:g_suite1) }
  let(:g_suite_id) { g_suite.id }

  let(:recipient) { 'email@mailinator.com' }
  
  describe '#notify_of_configuring' do
    let(:mailer) { GSuiteMailer.with(g_suite_id: g_suite_id, recipient: recipient).notify_of_configuring }

    it 'renders to' do
      expect(mailer.to).to eql([recipient])
    end

    it 'renders subject' do
      expect(mailer.subject).to eql('[Action Requested] Your G Suite for event1.example.com needs configuration')
    end

    it 'includes g suite overview url in body' do
      expect(mailer.body).to include('http://example.com/event1/g_suite')
    end
  end

  describe '#notify_of_verified' do
    let(:mailer) { GSuiteMailer.with(g_suite_id: g_suite_id, recipient: recipient).notify_of_verified }

    it 'renders to' do
      expect(mailer.to).to eql([recipient])
    end

    it 'renders subject' do
      expect(mailer.subject).to eql('[G Suite Verified] Your G Suite for event1.example.com has been verified')
    end

    it 'includes g suite overview url in body' do
      expect(mailer.body).to include('http://example.com/event1/g_suite')
    end
  end
end
