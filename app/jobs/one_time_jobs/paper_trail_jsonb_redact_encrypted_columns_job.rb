# frozen_string_literal: true

module OneTimeJobs
  class PaperTrailJsonbRedactEncryptedColumnsJob < ApplicationJob
    MODELS_TO_ENCRYPTED_COLUMNS = {
      User          => ["api_access_token"],
      Comment       => ["content"],
      Partner       => ["stripe_api_key", "api_key"],
      Check         => ["description"],
      BankAccount   => ["plaid_access_token"],
      UserSession   => ["session_token"],
      Invoice       => ["payment_method_ach_credit_transfer_account_number"],
      AchTransfer   => ["account_number"],
      GSuiteAccount => ["initial_password"],
    }.freeze

    def perform
      MODELS_TO_ENCRYPTED_COLUMNS.each_key do |model_class|
        PaperTrail::Version
          .where(id: 160358..160400)
          .where(item_type: model_class.to_s)
          .find_each do |version|

          encrypted_columns = MODELS_TO_ENCRYPTED_COLUMNS[model_class]

          if version.object
            object_redacted = version.object
                                     .except(*encrypted_columns) # remove non ciphertext versions of columns that are now encrypted from the papertrail history
            version.update_column(:object, object_redacted)
          end

          if version.object_changes
            object_changes_redacted = version.object_changes
                                             .except(*encrypted_columns)
            version.update_column(:object_changes, object_changes_redacted)
          end
        end
      end
    end

  end
end
