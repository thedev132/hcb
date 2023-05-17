# frozen_string_literal: true

class HcbCodesController < ApplicationController
  skip_before_action :signed_in_user, only: [:receipt, :attach_receipt, :show]
  skip_after_action :verify_authorized, only: [:receipt]

  def show
    @hcb_code = HcbCode.find_by(hcb_code: params[:id]) || HcbCode.find(params[:id])
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

  def edit
    @hcb_code = HcbCode.find_by(hcb_code: params[:id]) || HcbCode.find(params[:id])
    @event = @hcb_code.event

    authorize @hcb_code

    @frame = turbo_frame_request?
    @suggested_memos = ::HcbCodeService::SuggestedMemos.new(hcb_code: @hcb_code, event: @event).run.first(4)
  end

  def update
    @hcb_code = HcbCode.find_by(hcb_code: params[:id]) || HcbCode.find(params[:id])

    authorize @hcb_code
    hcb_code_params = params.require(:hcb_code).permit(:memo)
    hcb_code_params[:memo] = hcb_code_params[:memo].presence

    @hcb_code.canonical_transactions.update_all(custom_memo: hcb_code_params[:memo])
    @hcb_code.canonical_pending_transactions.update_all(custom_memo: hcb_code_params[:memo])

    redirect_to @hcb_code
  end

  def comment
    @hcb_code = HcbCode.find(params[:id])

    authorize @hcb_code

    ::HcbCodeService::Comment::Create.new(
      hcb_code_id: @hcb_code.id,
      content: params[:content],
      file: params[:file],
      admin_only: params[:admin_only],
      current_user: current_user
    ).run

    redirect_to params[:redirect_url]
  rescue => e
    redirect_to params[:redirect_url], flash: { error: e.message }
  end

  include HcbCodeHelper # for disputed_transactions_airtable_form_url and attach_receipt_url

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
