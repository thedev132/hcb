# frozen_string_literal: true

class AddHasFiscalSponsorshipDocumentToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :has_fiscal_sponsorship_document, :boolean
  end
end
