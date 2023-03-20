# frozen_string_literal: true

class IncreaseService
  module AccountIds
    def increase_environment
      if Rails.env.production?
        :production
      else
        :sandbox
      end
    end

    def fs_main_account_id
      Rails.application.credentials.dig(:increase, increase_environment, :fs_main_account_id)
    end

    def fs_operating_account_id
      Rails.application.credentials.dig(:increase, increase_environment, :fs_operating_account_id)
    end
  end

  include AccountIds

  def initialize
    @conn = Faraday.new url: increase_url do |f|
      f.request :authorization, "Bearer", increase_api_key
      f.request :json
      f.response :json
      f.response :raise_error
    end
  end

  def get(url, params = {})
    @conn.get(url, params).body
  end

  def post(url, params = {})
    @conn.post(url, params).body
  end

  def transfer(from:, to:, amount:, memo:)
    post "/account_transfers", {
      account_id: from,
      destination_account_id: to,
      amount: amount,
      description: memo
    }
  end

  private

  def increase_url
    if increase_environment == :production
      "https://api.increase.com"
    else
      "https://sandbox.increase.com"
    end
  end

  def increase_api_key
    Rails.application.credentials.dig(:increase, increase_environment, :api_key)
  end

end
