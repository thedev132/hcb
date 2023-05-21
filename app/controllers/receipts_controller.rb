# frozen_string_literal: true

class ReceiptsController < ApplicationController
  skip_after_action :verify_authorized, only: :upload # do not force pundit
  skip_before_action :signed_in_user, only: :upload
  before_action :set_paper_trail_whodunnit, only: :upload
  before_action :find_receiptable, only: [:upload, :link, :link_modal]

  def destroy
    @receipt = Receipt.find(params[:id])
    @receiptable = @receipt.receiptable
    authorize @receipt

    if @receipt.delete
      flash[:success] = "Deleted receipt"
      redirect_to @receiptable || my_inbox_path
    else
      flash[:error] = "Failed to delete receipt"
      redirect_to @receiptable
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

    if params[:show_link]
      flash[:success] = { text: "Receipt linked!", link: (hcb_code_path(@receiptable) if @receiptable.instance_of?(HcbCode)), link_text: "View" }
    else
      flash[:success] = "Receipt added!"
    end

    redirect_back fallback_location: @receiptable.try(:hcb_code) || @receiptable
  end

  def link_modal
    @receipts = Receipt.where(user: current_user, receiptable: nil)

    authorize @receiptable, policy_class: ReceiptablePolicy

    render :link_modal, layout: false
  end


  def upload
    params.require(:file)
    params.require(:upload_method)

    begin
      if @receiptable
        authorize @receiptable, policy_class: ReceiptablePolicy
      end
    rescue Pundit::NotAuthorizedError
      @has_valid_secret = @receiptable.instance_of?(HcbCode) && HcbCodeService::Receipt::SigningEndpoint.new.valid_url?(@receiptable.hashid, params[:s])

      raise unless @has_valid_secret
    end

    if params[:file] # Ignore if no files were uploaded
      params[:file].each do |file|
        ::ReceiptService::Create.new(
          receiptable: @receiptable,
          uploader: current_user,
          attachments: [file],
          upload_method: params[:upload_method]
        ).run!
      end

      if params[:show_link]
        flash[:success] = { text: "#{"Receipt".pluralize(params[:file].length)} added!", link: (hcb_code_path(@receiptable) if @receiptable.instance_of?(HcbCode)), link_text: "View" }
      else
        flash[:success] = "#{"Receipt".pluralize(params[:file].length)} added!"
      end
    end
  rescue => e
    notify_airbrake(e)

    flash[:error] = e.message
  ensure
    if params[:redirect_url]
      redirect_to params[:redirect_url]
    else
      redirect_back fallback_location: @receiptable&.try(:url) || @receiptable || my_inbox_path
    end
  end

  private

  def find_receiptable
    if params[:receiptable_type].present? && params[:receiptable_id].present?
      @klass = params[:receiptable_type].constantize
      @receiptable = @klass.find(params[:receiptable_id])
    end
  end

end
