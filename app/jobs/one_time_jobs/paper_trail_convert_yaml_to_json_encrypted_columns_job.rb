# frozen_string_literal: true

module OneTimeJobs
  class PaperTrailConvertYamlToJsonEncryptedColumnsJob < ApplicationJob
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
          .where(object: nil, object_changes: nil, item_type: model_class.to_s)
          .find_each do |version|

          # rubocop:disable Security/YAMLLoad
          if version.old_object
            old_object = YAML.load(version.old_object)

            encrypted_columns = MODELS_TO_ENCRYPTED_COLUMNS[model_class]
            old_object_redacted = old_object
                                  .except(*encrypted_columns) # remove non ciphertext versions of columns that are now encrypted from the papertrail history
                                  .tap do |hash|
              encrypted_columns.each do |column|
                next unless old_object[column]

                # Adds ciphertext version of encrypted column, so we are still storing history but it is encrypted at the PaperTrail level too
                # e.g. calls User.generate_api_access_token_ciphertext(old_object["api_access_token"])
                hash["#{column}_ciphertext"] = model_class.send("generate_#{column}_ciphertext", old_object[column])
              end
            end

            version.update_column(
              :object,
              old_object_redacted
            )
          end

          if version.old_object_changes
            old_object_changes = YAML.load(version.old_object_changes)

            encrypted_columns = MODELS_TO_ENCRYPTED_COLUMNS[model_class]
            old_object_changes_redacted = old_object_changes
                                          .except(*encrypted_columns)
                                          .tap do |hash|
              encrypted_columns.each do |column|
                next unless old_object_changes[column]

                # We are replacing plaintext columns with the ciphertext version (same principle as object/old_object above), except
                # for object_changes/old_object_changes, they are a 2 element array of the before and after values, so we have to store
                # a 2 element array of before/after for the ciphertext columns too
                hash["#{column}_ciphertext"] = [
                  model_class.send("generate_#{column}_ciphertext", old_object_changes[column][0]),
                  model_class.send("generate_#{column}_ciphertext", old_object_changes[column][1]),
                ]
              end
            end

            version.update_column(
              :object_changes,
              old_object_changes_redacted
            )
          end
          # rubocop:enable Security/YAMLLoad
        end
      end
    end

  end
end
