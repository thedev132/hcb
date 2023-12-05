# frozen_string_literal: true

module MetricJobs
  class CalculateAppWide < ApplicationJob
    queue_as :low

    def perform
      metric_classes.each do |metric_class|
        MetricJobs::CalculateSingle.perform_later(metric_class)
      end
    end

    private

    def metric_classes
      Metric.descendants.select do |c|
        c.included_modules.include?(Metric::AppWide)
      end
    end

  end
end
