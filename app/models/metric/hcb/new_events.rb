# frozen_string_literal: true

# == Schema Information
#
# Table name: metrics
#
#  id           :bigint           not null, primary key
#  metric       :jsonb
#  subject_type :string
#  type         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  subject_id   :bigint
#
# Indexes
#
#  index_metrics_on_subject  (subject_type,subject_id)
#
class Metric
  module Hcb
    class NewEvents < Metric
      include AppWide

      def calculate
        ::Event.not_omitted
               .not_hidden
               .not_demo_mode
               .approved
               .where("EXTRACT(YEAR FROM events.created_at) = ?", 2024)
               .count
      end

    end
  end

end
