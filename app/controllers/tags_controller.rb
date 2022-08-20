# frozen_string_literal: true

class TagsController < ApplicationController
  include SetEvent

  before_action :set_event

  def create
    authorize @event, policy_class: TagPolicy

    tag = @event.tags.build(label: params[:label].strip)
    if !tag.save
      flash[:error] = "That tag already exists."
    elsif params[:hcb_code_id]
      hcb_code = HcbCode.find(params[:hcb_code_id])
      authorize hcb_code, :toggle_tag?

      hcb_code.tags << tag
    end

    redirect_back fallback_location: @event
  end

end
