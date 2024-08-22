# frozen_string_literal: true

# == Schema Information
#
# Table name: event_plans
#
#  id         :bigint           not null, primary key
#  aasm_state :string
#  plan_type  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint           not null
#
# Indexes
#
#  index_event_plans_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => events.id)
#
class Event
  class Plan < ApplicationRecord
    belongs_to :event

    include AASM

    aasm do
      state :active, initial: true
      state :inactive

      event :mark_inactive do
        transitions from: :active, to: :inactive
      end
    end

    def standard?
      plan_type == Event::Plan::Standard.name
    end

    def revenue_fee_label
      ActionController::Base.helpers.number_to_percentage(revenue_fee * 100, precision: 1)
    end

    def self.available_features
      # this must contain every HCB feature that we want enable / disable with plans.
      %w[cards invoices donations account_number check_deposits transfers promotions google_workspace documentation settings reimbursements]
    end

    self.available_features.each do |feature|
      define_method("#{feature}_enabled?") do
        feature.in?(features)
      end
    end

    def self.available_plans
      plans = Event::Plan.subclasses
      Event::Plan.subclasses.each do |subclass|
        plans += subclass.subclasses
      end
      plans
    end

  end

end
