# frozen_string_literal: true

class SuggestedPairingsController < ApplicationController
  def ignore
    @pairing = SuggestedPairing.find(params[:id])
    authorize @pairing

    @pairing.mark_ignored!

    flash[:success] = "Suggestion ignored"
    redirect_back fallback_location: my_inbox_path
  end

  def accept
    @pairing = SuggestedPairing.find(params[:id])
    authorize @pairing

    @pairing.mark_accepted!

    flash[:success] = { text: "Receipt linked!", link: hcb_code_path(@pairing.hcb_code), link_text: "View" }
    redirect_back fallback_location: my_inbox_path
  end

end
