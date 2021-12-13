# frozen_string_literal: true

class ReportsController < ApplicationController
  def fees
    @event = Event.find(params[:id])

    authorize @event

    respond_to do |format|
      format.csv { stream_fees_csv }
    end
  end

  private

  def stream_fees_csv
    set_file_headers_csv
    set_streaming_headers

    response.status = 200

    self.response_body = fees_csv
  end

  def set_file_headers_csv
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=#{clean_event_name}_Hack_Club_Bank_Fees_(#{current_time}).csv"
  end

  def fees_csv
    ::FeeService::Report::Csv.new(event_id: @event.id).run
  end

  def clean_event_name
    @event.name.gsub!(/\s+/, "_").gsub!(/[^0-9A-Za-z_]/, "-")
  end

  def current_time
    Time.now.strftime("%m_%d_%Y")
  end
end
