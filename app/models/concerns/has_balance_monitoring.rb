# frozen_string_literal: true

module HasBalanceMonitoring
  extend ActiveSupport::Concern

  included do
    after_save do
      CheckBalanceJob.set(wait: 5.minutes).perform_later(event: self)
    end
  end
end
