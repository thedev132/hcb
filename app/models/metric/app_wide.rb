# frozen_string_literal: true

class Metric
  module AppWide
    # App Wide Metrics (namespaced under the Hcb module) essentially act as
    # singletons. They don't have a subject and have a `instance` method that
    # returns the single instance (record) of the metric.
    extend ActiveSupport::Concern

    included do
      # Metrics that don't have a subject (subject_id, subject_type) are application-wide metrics
      validates :subject, absence: true

      def self.instance
        self.from(nil)
      end

      def self.metric
        instance.metric
      end
    end
  end

end
