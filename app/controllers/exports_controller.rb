# frozen_string_literal: true

class ExportsController < ApplicationController
  def financial_export
    f = FinancialExport.new(user: current_user)
    authorize f

    @events = Event.all.order(id: :asc)

    if f.save
      render xlsx: "financial_export"
    else
      render_text "Error!"
    end
  end
end
