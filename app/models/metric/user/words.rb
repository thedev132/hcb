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
  module User
    class Words < Metric
      include Subject

      def calculate
        user.organizer_positions
            .map { |o| ::Metric::Event::Words.from(::Event.find(o.event.id)).metric }
            .inject{ |memo, el| memo.merge( el ){ |k, old_v, new_v| old_v + new_v } }
      end

    end
  end

end
