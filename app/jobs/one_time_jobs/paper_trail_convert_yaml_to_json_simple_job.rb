# frozen_string_literal: true

module OneTimeJobs
  class PaperTrailConvertYamlToJsonSimpleJob < ApplicationJob
    # These are simple because they don't have lockbox encrypted columns that require redaction
    SIMPLE_ITEM_TYPES = [PartnerDonation, CanonicalTransaction, FeeReimbursement, Event, HcbCode, StripeAuthorization, Fee, DonationPayout, InvoicePayout, LoginToken, Donation, Disbursement, PartneredSignup, GSuite, Sponsor, OrganizerPositionInvite, OrganizerPositionDeletionRequest, BankFee, StripeCard, CanonicalPendingTransaction].freeze

    def perform
      PaperTrail::Version
        .where(object: nil, object_changes: nil, item_type: SIMPLE_ITEM_TYPES.map(&:to_s))
        .find_each do |version|

        # rubocop:disable Security/YAMLLoad
        if version.old_object
          version.update_column(
            :object,
            YAML.load(version.old_object)
          )
        end

        if version.old_object_changes
          version.update_column(
            :object_changes,
            YAML.load(version.old_object_changes)
          )
        end
        # rubocop:enable Security/YAMLLoad
      end

    end

  end
end
