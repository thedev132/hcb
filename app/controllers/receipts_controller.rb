# frozen_string_literal: true

class ReceiptsController < ApplicationController
  skip_after_action :verify_authorized, only: :create # do not force pundit
  skip_before_action :signed_in_user, only: :create
  before_action :set_paper_trail_whodunnit, only: :create
  before_action :find_receiptable, only: [:create, :link, :link_modal]

  def destroy
    @receipt = Receipt.find(params[:id])
    @receiptable = @receipt.receiptable
    authorize @receipt

    success = @receipt.delete

    respond_to do |format|
      format.turbo_stream { render turbo_stream: generate_streams }
      format.html         {
        if params[:popover]&.starts_with?("HcbCode:")
          flash[:popover] = params[:popover].gsub("HcbCode:", "")
        end

        if success
          flash[:success] = "Deleted receipt"
          redirect_back fallback_location: @receiptable || my_inbox_path
        else
          flash[:error] = "Failed to delete receipt"
          redirect_back fallback_location: @receiptable || my_inbox_path
        end
      }
    end
  end

  def link
    params.require(:receipt_id)
    params.require(:receiptable_type)
    params.require(:receiptable_id)

    @receipt = Receipt.find(params[:receipt_id])

    authorize @receipt
    authorize @receiptable, policy_class: ReceiptablePolicy

    @receipt.update!(receiptable: @receiptable)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: generate_streams }
      format.html         {
        if params[:show_link]
          flash[:success] = { text: "Receipt linked!", link: (hcb_code_path(@receiptable) if @receiptable.instance_of?(HcbCode)), link_text: "View" }
        else
          flash[:success] = "Receipt added!"
        end

        if params[:popover]&.starts_with?("HcbCode:")
          flash[:popover] = params[:popover].gsub("HcbCode:", "")
        end

        if params[:redirect_url]
          redirect_to params[:redirect_url]
        else
          redirect_back fallback_location: @receiptable.try(:hcb_code) || @receiptable
        end
      }
    end
  end

  def link_modal
    authorize @receiptable, policy_class: ReceiptablePolicy

    @receipts = Receipt.in_receipt_bin.where(user: current_user).order(created_at: :desc)
    @show_link = params[:show_link]
    @streams = defined?(params[:streams]) ? params[:streams] : true
    @suggested_receipt_ids = []

    if params[:popover].present?
      @popover = params[:popover]
    end

    if @receiptable.instance_of?(HcbCode)
      pairings_sql = <<~SQL
        LEFT JOIN (#{@receiptable.suggested_pairings.to_sql}) sp
        ON sp.receipt_id = receipts.id
      SQL
      @receipts = @receipts.joins(pairings_sql).reorder("sp.distance ASC, receipts.created_at DESC")
      @suggested_receipt_ids = @receipts.limit(3).where("sp.distance <= ?", 1000).pluck(:id)
    end

    render :link_modal, layout: false

  end



  def create
    streams = []

    params.require(:file)
    params.require(:upload_method)

    begin
      if @receiptable
        authorize @receiptable, :upload?, policy_class: ReceiptablePolicy
      end
    rescue Pundit::NotAuthorizedError
      raise unless @receiptable.is_a?(HcbCode) && HcbCode.find_signed(params[:s], purpose: :receipt_upload) == @receiptable
    end

    return unless params[:file].present?

    streams = []

    params[:file].map do |file|
      (receipt, ) = ::ReceiptService::Create.new(
        receiptable: @receiptable,
        uploader: current_user,
        attachments: [file],
        upload_method: params[:upload_method]
      ).run!
      next if @receiptable

      streams.append(turbo_stream.prepend(
                       :receipts_list,
                       partial: "receipts/receipt",
                       locals: { receipt:, show_delete_button: true, link_to_file: true }
                     ))
    end

    streams += generate_streams

    unless @receiptable
      streams.append(
        turbo_stream.replace(
          :receipt_upload_form,
          partial: "receipts/form_v3", locals: {
            upload_method: "receipt_center",
            restricted_dropzone: true,
            success: "#{"Receipt".pluralize(params[:file].length)} added!"
          }
        )
      )
    end

    flash_type = :success
    if params[:show_link]
      flash_message = { text: "#{"Receipt".pluralize(params[:file].length)} added!", link: (hcb_code_path(@receiptable) if @receiptable.instance_of?(HcbCode)), link_text: "View" }
    else
      flash_message = "#{"Receipt".pluralize(params[:file].length)} added!"
    end

  rescue => e
    notify_airbrake(e)

    flash_type = :error
    flash_message = e.message

    streams.append(
      turbo_stream.replace(
        :receipt_upload_form,
        partial: "receipts/form_v3", locals: {
          upload_method: "receipt_center",
          restricted_dropzone: true,
          error: e.message
        }
      )
    )
  ensure
    respond_to do |format|
      format.turbo_stream { render turbo_stream: streams }
      format.html         {
        flash[flash_type] = flash_message if flash_message && flash_type
        if params[:redirect_url]
          redirect_to params[:redirect_url]
        elsif @receiptable.is_a?(HcbCode) && @receiptable.stripe_card&.card_grant.present?
          redirect_to @receiptable.stripe_card.card_grant
        else
          if params[:popover]&.starts_with?("HcbCode:")
            flash[:popover] = params[:popover].gsub("HcbCode:", "")
          end

          redirect_back fallback_location: URI.parse(@receiptable&.try(:url) || url_for(@receiptable) || my_inbox_path)
        end
      }
    end
  end

  private

  def find_receiptable
    if params[:receiptable_type].present? && params[:receiptable_id].present?
      @klass = params[:receiptable_type].constantize
      @receiptable = @klass.find(params[:receiptable_id])
    end
  end

  def generate_streams
    streams = []

    streams.append(
      turbo_stream.replace(
        "suggested_pairings",
        partial: "static_pages/suggested_pairings",
        locals: { pairings: current_user.receipt_bin.suggested_receipt_pairings, current_slide: 0 }
      )
    )

    if @receiptable
      if @receiptable.canonical_transactions&.any?
        @receiptable.canonical_transactions.each do |ct|
          streams.append(turbo_stream.replace(
                           ct.local_hcb_code.hashid,
                           partial: "canonical_transactions/canonical_transaction",
                           locals: { ct:, force_display_details: true, receipt_upload_button: true, show_event_name: true, updated_via_turbo_stream: true }
                         ))
        end
      else
        @receiptable.canonical_pending_transactions&.each do |pt|
          streams.append(turbo_stream.replace(
                           pt.local_hcb_code.hashid,
                           partial: "canonical_pending_transactions/canonical_pending_transaction",
                           locals: { pt:, force_display_details: true, receipt_upload_button: true, show_event_name: true, updated_via_turbo_stream: true }
                         ))
        end
      end
    end

    if @receipt
      streams.append(turbo_stream.remove("receipt_#{@receipt.id}"))
    end

    streams.append(turbo_stream.refresh_link_modals)

    streams.append(
      turbo_stream.replace(
        "receipts_blankslate",
        partial: "receipts/blankslate", locals: {
          count: Receipt.in_receipt_bin.where(user: current_user).count
        }
      )
    )

    streams
  end

end
