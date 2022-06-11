# frozen_string_literal: true

require "rails_helper"

RSpec.describe PendingTransactionEngine do

  # TODO: move this method into business logic and use in view as well as this test
  def incoming_deposits(event)
    event.canonical_pending_transactions.incoming.unsettled.sum(:amount_cents)
  end

  describe "disbursement moves pending money" do
    def create_partner
      Partner.create!({
                        slug: SecureRandom.hex(30)
                      })
    end

    def create_event(name, partner)
      Event.create!({
                      name: name,
                      partner_id: partner.id,
                      sponsorship_fee: 0,
                      organization_identifier: SecureRandom.hex(30)
                    })
    end

    def create_disbursement(source_event, destination_event)
      Disbursement.create!({
                             event: destination_event,
                             source_event: source_event,
                             amount: 100,
                             name: 'for fun'
                           })
    end

    it "creates valid setup data" do
      partner = create_partner
      source_event = create_event('source hacks', partner)
      destination_event = create_event('destination hacks', partner)
      disbursement = create_disbursement(source_event, destination_event)

      expect(source_event).to be_valid
      expect(destination_event).to be_valid
      expect(disbursement).to be_valid
    end

    it "creates raw incoming and outgoing transactions" do
      partner = create_partner
      source_event = create_event('source hacks', partner)
      destination_event = create_event('destination hacks', partner)
      disbursement = create_disbursement(source_event, destination_event)

      expect(disbursement.raw_pending_incoming_disbursement_transaction).to eq(nil)
      expect(disbursement.raw_pending_outgoing_disbursement_transaction).to eq(nil)

      cpt_count = CanonicalPendingTransaction.count

      # Act
      ::PendingTransactionEngine::RawPendingIncomingDisbursementTransactionService::Disbursement::Import.new.run
      ::PendingTransactionEngine::RawPendingOutgoingDisbursementTransactionService::Disbursement::Import.new.run

      ::PendingTransactionEngine::CanonicalPendingTransactionService::Import::IncomingDisbursement.new.run
      ::PendingTransactionEngine::CanonicalPendingTransactionService::Import::OutgoingDisbursement.new.run

      # Assert
      disbursement.reload
      expect(disbursement.raw_pending_incoming_disbursement_transaction).to be_present
      expect(disbursement.raw_pending_outgoing_disbursement_transaction).to be_present

      expect(CanonicalPendingTransaction.count).to eq(cpt_count + 2)
    end

    it "increments the incoming deposit total" do
      partner = create_partner
      source_event = create_event('source hacks', partner)
      destination_event = create_event('destination hacks', partner)
      create_disbursement(source_event, destination_event)

      incoming_amount = incoming_deposits destination_event

      ::PendingTransactionEngine::RawPendingIncomingDisbursementTransactionService::Disbursement::Import.new.run
      ::PendingTransactionEngine::RawPendingOutgoingDisbursementTransactionService::Disbursement::Import.new.run

      ::PendingTransactionEngine::CanonicalPendingTransactionService::Import::IncomingDisbursement.new.run
      ::PendingTransactionEngine::CanonicalPendingTransactionService::Import::OutgoingDisbursement.new.run

      ::PendingEventMappingEngine::Map::IncomingDisbursement.new.run
      ::PendingEventMappingEngine::Map::OutgoingDisbursement.new.run
      ::PendingEventMappingEngine::Settle::IncomingDisbursementHcbCode.new.run
      ::PendingEventMappingEngine::Settle::OutgoingDisbursementHcbCode.new.run
      ::PendingEventMappingEngine::Decline::IncomingDisbursement.new.run
      ::PendingEventMappingEngine::Decline::OutgoingDisbursement.new.run

      expect(incoming_deposits(destination_event)).to eq(incoming_amount + 100)

      # TODO: should we assert that the source_event has been decremented 100?
    end
  end
end
# setup
# - [x] 2 accounts, one with funds one without
# - [x] disbursement to provide funds
# test
# - run services to populate pending TXs
# validate
# - pending TXs should be created
# - budgets should update
# teardown
