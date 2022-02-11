# frozen_string_literal: true

class AddLegalAcknowledgementToPartneredSignups < ActiveRecord::Migration[6.0]
  def change
    add_column :partnered_signups, :legal_acknowledgement, :boolean
  end

end
