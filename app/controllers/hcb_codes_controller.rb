# frozen_string_literal: true

class HcbCodesController < ApplicationController
  skip_before_action :signed_in_user, only: [:receipt, :attach_receipt, :show]
  skip_after_action :verify_authorized, only: [:receipt]

  def show
    @hcb_code = HcbCode.find_by(hcb_code: params[:id]) || HcbCode.find(params[:id])

    if @hcb_code.no_transactions?
      raise ActiveRecord::RecordNotFound
    end

    @event =
      begin
        # Attempt to retrieve the event using the context of the
        # previous page. Has a high chance of erroring, but we'll give it
        # a shot.
        route = Rails.application.routes.recognize_path(request.referrer)
        model = route[:controller].classify.constantize
        object = model.find(route[:id])
        event = model == Event ? object : object.event
        raise StandardError unless @hcb_code.events.include? event

        event
      rescue
        @hcb_code.events.min_by do |e|
          [e.users.include?(current_user), e.is_public?].map { |b| b ? 0 : 1 }
        end
      rescue
        @hcb_code.event
      end

    hcb = @hcb_code.hcb_code
    hcb_id = @hcb_code.hashid

    authorize @hcb_code
  rescue Pundit::NotAuthorizedError => e
    raise unless @event.is_public?

    if @hcb_code.canonical_transactions.any?
      txs = TransactionGroupingEngine::Transaction::All.new(event_id: @event.id).run
      pos = txs.index { |tx| tx.hcb_code == hcb } + 1
      page = (pos.to_f / 100).ceil

      redirect_to event_path(@event, page: page, anchor: hcb_id)
    else
      redirect_to event_path(@event, anchor: hcb_id)
    end
  end

  def memo_frame
    @hcb_code = HcbCode.find(params[:id])
    authorize @hcb_code

    if params[:gen_memo]
      @ai_memo = HcbCodeService::AiGenerateMemo.new(hcb_code: @hcb_code).run
    end
  end

  def comment
    @hcb_code = HcbCode.find(params[:id])

    authorize @hcb_code

    attrs = {
      hcb_code_id: @hcb_code.id,
      content: params[:content],
      file: params[:file],
      admin_only: params[:admin_only],
      current_user: current_user
    }
    ::HcbCodeService::Comment::Create.new(attrs).run

    redirect_to params[:redirect_url]
  rescue => e
    redirect_to params[:redirect_url], flash: { error: e.message }
  end

  include HcbCodeHelper # for disputed_transactions_airtable_form_url and attach_receipt_url

  def receipt
    @hcb_code = HcbCode.find(params[:id])
    begin
      authorize @hcb_code
    rescue Pundit::NotAuthorizedError
      @has_valid_secret = HcbCodeService::Receipt::SigningEndpoint.new.valid_url?(@hcb_code.hashid, params[:s])

      raise unless @has_valid_secret
    end

    if params[:file] # Ignore if no files were uploaded
      params[:file].each do |file|
        attrs = {
          hcb_code_id: @hcb_code.id,
          file: file,
          upload_method: params[:upload_method],
          current_user: current_user
        }
        ::HcbCodeService::Receipt::Create.new(attrs).run
      end

      if params[:show_link]
        flash[:success] = { text: "Receipt".pluralize(params[:file].length) + " added!", link: hcb_code_path(@hcb_code), link_text: "View" }
      else
        flash[:success] = "Receipt".pluralize(params[:file].length) + " added!"
      end
    end

    return redirect_to params[:redirect_url] if params[:redirect_url]

    redirect_back fallback_location: @hcb_code.url

  rescue => e
    Airbrake.notify(e)

    redirect_to params[:redirect_url], flash: { error: e.message }
  end

  def attach_receipt
    @hcb_code = HcbCode.find(params[:id])
    @event = @hcb_code.event

    authorize @hcb_code

  rescue Pundit::NotAuthorizedError
    unless HcbCodeService::Receipt::SigningEndpoint.new.valid_url?(@hcb_code.hashid, params[:s])
      raise
    end

  end

  def send_receipt_sms
    @hcb_code = HcbCode.find(params[:id])

    authorize @hcb_code

    cpt = @hcb_code.canonical_pending_transactions.first

    CanonicalPendingTransactionJob::SendTwilioMessage.perform_now(cpt_id: cpt.id, user_id: current_user.id)

    flash[:success] = "SMS queued for delivery!"
    redirect_back fallback_location: @hcb_code
  end

  def dispute
    @hcb_code = HcbCode.find(params[:id])

    authorize @hcb_code

    can_dispute, error_reason = ::HcbCodeService::CanDispute.new(hcb_code: @hcb_code).run

    if can_dispute
      redirect_to disputed_transactions_airtable_form_url(embed: false, hcb_code: @hcb_code, user: @current_user), allow_other_host: true
    else
      redirect_to @hcb_code, flash: { error: error_reason }
    end
  end

  def toggle_tag
    hcb_code = HcbCode.find(params[:id])
    tag = Tag.find(params[:tag_id])

    authorize hcb_code
    authorize tag

    raise Pundit::NotAuthorizedError unless hcb_code.events.include?(tag.event)

    if hcb_code.tags.exists?(tag.id)
      hcb_code.tags.destroy(tag)
    else
      hcb_code.tags << tag
    end

    redirect_back fallback_location: @event
  end

end
