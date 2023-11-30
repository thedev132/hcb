# frozen_string_literal: true


class ExportsController < ApplicationController
  skip_before_action :signed_in_user
  skip_after_action :verify_authorized, only: [:transactions, :collect_email]

  def transactions
    @event = Event.friendly.find(params[:event])

    if !@event.is_public?
      authorize @event.canonical_transactions.first, :show? # temporary hack for policies
    end

    # 300 is slightly arbitrary. HQ didn't run into issues until 5k
    should_queue = @event.canonical_transactions.size > 300

    respond_to do |format|
      format.csv do
        if should_queue
          if current_user
            ExportJob::Csv.perform_later(event_id: @event.id, user_id: current_user.id)
            flash[:success] = "This export is too big, so we'll send you an email when it's ready."
            redirect_back fallback_location: @event and return
          elsif params[:email]
            # this handles the second stage of large transparent exports
            ExportJob::Csv.perform_later(event_id: @event.id, email: params[:email])
            flash[:success] = "We'll send you an email when your export is ready."
            redirect_to @event and return
          else
            # handles when large exports are requested by the non-signed-in users viewing transparent orgs
            # this redirects them to a form that collects their email and then goes to the above statement
            redirect_to collect_email_exports_path(file_extension: "csv", event_slug: params[:event]) and return
          end
        end

        stream_transactions_csv
      end

      format.json do
        if should_queue
          if current_user
            ExportJob::Json.perform_later(event_id: @event.id, user_id: current_user.id)
            flash[:success] = "This export is too big, so we'll send you an email when it's ready."
            redirect_back fallback_location: @event and return
          elsif params[:email]
            # this handles the second stage of large transparent exports
            ExportJob::Json.perform_later(event_id: @event.id, email: params[:email])
            flash[:success] = "We'll send you an email when your export is ready."
            redirect_to @event and return
          else
            # handles when large exports are requested by the non-signed-in users viewing transparent orgs
            # this redirects them to a form that collects their email and then goes to the above statement
            redirect_to collect_email_exports_path(file_extension: "json", event_slug: params[:event]) and return
          end
        end

        stream_transactions_json
      end

      format.ledger do
        if should_queue
          if current_user
            ExportJob::Ledger.perform_later(event_id: @event.id, user_id: current_user.id)
            flash[:success] = "This export is too big, so we'll send you an email when it's ready."
            redirect_back fallback_location: @event and return
          elsif params[:email]
            # this handles the second stage of large transparent exports
            ExportJob::Ledger.perform_later(event_id: @event.id, email: params[:email])
            flash[:success] = "We'll send you an email when your export is ready."
            redirect_back fallback_location: @event and return
          else
            # handles when large exports are requested by the non-signed-in users viewing transparent orgs
            # this redirects them to a form that collects their email and then goes to the above statement
            redirect_to collect_email_exports_path(file_extension: "ledger", event_slug: params[:event]) and return
          end
        end

        stream_transactions_ledger
      end
    end
  end

  def collect_email
    if !params[:event_slug] || !params[:file_extension]
      redirect_to root_path
    end
    @event_slug = params[:event_slug]
    @file_extension = params[:file_extension]
  end

  private

  def stream_transactions_csv
    set_file_headers_csv
    set_streaming_headers

    response.status = 200

    self.response_body = transactions_csv
  end

  def stream_transactions_json
    set_file_headers_json
    set_streaming_headers

    response.status = 200

    self.response_body = transactions_json
  end

  def stream_transactions_ledger
    set_file_headers_ledger
    set_streaming_headers

    response.status = 200

    self.response_body = transactions_ledger
  end

  def set_file_headers_csv
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=transactions.csv"
  end

  def set_file_headers_json
    headers["Content-Type"] = "application/json"
    headers["Content-disposition"] = "attachment; filename=transactions.json"
  end

  def set_file_headers_ledger
    headers["Content-Type"] = "text/ledger"
    headers["Content-disposition"] = "attachment; filename=transactions.ledger"
  end

  def transactions_csv
    ::ExportService::Csv.new(event_id: @event.id).run
  end

  def transactions_json
    ::ExportService::Json.new(event_id: @event.id).run
  end

  def transactions_ledger
    ::ExportService::Ledger.new(event_id: @event.id).run
  end

end
