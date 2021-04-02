class HcbCodesController < ApplicationController
  skip_before_action :signed_in_user, only: [:receipt, :attach_receipt]

  def show
    @hcb_code = HcbCode.find(params[:id])

    authorize @hcb_code

    @event = @hcb_code.event
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

  def receipt
    @hcb_code = HcbCode.find(params[:id])

    authorize @hcb_code

    attrs = {
      hcb_code_id: @hcb_code.id,
      file: params[:file],
      current_user: current_user
    }
    ::HcbCodeService::Receipt::Create.new(attrs).run

    redirect_to params[:redirect_url]
  rescue => e
    redirect_to params[:redirect_url], flash: { error: e.message }
  end

  def attach_receipt
    @hcb_code = HcbCode.find(params[:id])

    authorize @hcb_code
  end

  private

  def redirect_unless_in_grace_window!
    redirect_to hcb_code_path(@hcb_code.hashid) and return if @hcb_code.date < Time.now.utc - 10.days # grace window
  end

end
