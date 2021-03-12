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
    headers["Content-disposition"] = "attachment; filename=fees.csv"
  end

  def fees_csv
    ::FeeService::Report::Csv.new(event_id: @event.id).run
  end
end
