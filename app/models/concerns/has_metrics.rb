# frozen_string_literal: true

module HasMetrics
  extend ActiveSupport::Concern

  included do
    has_many :metrics, dependent: :destroy
  end
end
