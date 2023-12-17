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

class Metric < ApplicationRecord
  after_initialize do
    raise "Cannot directly instantiate a Metric" if self.instance_of? Metric
  end

  before_create :populate
  belongs_to :subject, polymorphic: true, optional: true # if missing, it's an application-wide metric

  def populate
    self.metric = calculate
  end

  def calculate
    raise UnimplementedError
  end

  def geocode(location)
    loc_array = location.split(" - ")
    zip = loc_array.last
    unless zip == "000000"
      geocode = Geocoder.search(location)[0]
      if geocode.present?
        address = Geocoder.search(location)[0]&.data&.[]("address")
        if address["town"]
          return "#{loc_array[0, loc_array.length - 1].join(" - ")} - #{address["town"]}"
        elsif address["city"]
          return "#{loc_array[0, loc_array.length - 1].join(" - ")} - #{address["city"]}"
        elsif address["county"]
          return "#{loc_array[0, loc_array.length - 1].join(" - ")} - #{address["county"]}"
        end

      end
    end
    return loc_array[0, loc_array.length - 1].join(" - ")
  end

  def self.from(subject, repopulate: false)
    metric = self.find_by(subject:)
    return self.create(subject:) if metric.nil?

    if repopulate
      metric.populate
      unless metric.save
        metric.reload
        Airbrake.notify("Failed to save metric #{metric.inspect}")
      end
    end

    metric
  end

end
