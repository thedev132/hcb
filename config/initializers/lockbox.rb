# frozen_string_literal: true

# https://github.com/ankane/lockbox

Lockbox.master_key = Rails.application.credentials.lockbox[:master_key]
