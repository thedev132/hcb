# frozen_string_literal: true

require "google/apis/admin_directory_v1"
require "googleauth"
require "googleauth/stores/file_token_store"

Google::Apis.logger.level = Rails.env.production? ? Logger::FATAL : Logger::DEBUG
