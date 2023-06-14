# frozen_string_literal: true

class IncreaseService
  def self.environment
    if Rails.env.production?
      :production
    else
      :sandbox
    end
  end

  module AccountIds
    private_class_method def self.get_id(account_name)
      id = Rails.application.credentials.dig(:increase, IncreaseService.environment, "#{account_name}_account_id".to_sym)
      raise ArgumentError, "No Increase account id for #{account_name}" unless id

      id
    end

    FS_MAIN = get_id(:fs_main)
    DAF_MAIN = get_id(:daf_main)
    FS_OPERATING = get_id(:fs_operating)
  end

end
