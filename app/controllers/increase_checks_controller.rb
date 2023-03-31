# frozen_string_literal: true

class IncreaseChecksController < ApplicationController
  include SetEvent

  before_action :set_event, only: %i[new create]
  before_action :set_check, only: %i[approve reject]

  def new
    @check = @event.increase_checks.build

    authorize @check
  end

  def create
    params[:increase_check][:amount] = Monetize.parse(params[:increase_check][:amount]).cents

    @check = @event.increase_checks.build(check_params.merge(user: current_user))
    authorize @check

    if @check.save
      redirect_to @check.local_hcb_code.url, flash: { success: "Your check has been sent!" }
    else
      render "new", status: :unprocessable_entity
    end
  end

  def approve
    authorize @check

    @check.send_check!

    redirect_to increase_check_process_admin_path(@check), flash: { success: "Check has been sent!" }

  rescue => e
    redirect_to increase_check_process_admin_path(@check), flash: { error: e }
  end

  def reject
    authorize @check

    @check.mark_rejected!

    redirect_to increase_check_process_admin_path(@check), flash: { success: "Check has been rejected!" }
  end

  private

  def check_params
    params.require(:increase_check).permit(
      :memo,
      :amount,
      :payment_for,
      :recipient_name,
      :address_line1,
      :address_line2,
      :address_city,
      :address_state,
      :address_zip,
    )
  end

  def set_check
    @check = IncreaseCheck.find(params[:id])
  end

end
