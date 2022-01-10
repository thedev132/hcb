# frozen_string_literal: true

class PartnerDocusignSupport < ActiveRecord::Migration[6.0]
  def change
    # the actual "envelope" or package that users are supposed to sign
    add_column :partnered_signups, :docusign_envelope_id, :string
    add_column :partnered_signups, :signed_contract, :boolean
    # Template ID that we can use to do the partnered sign ups
    add_column :partners, :docusign_template_id, :string
  end

end
