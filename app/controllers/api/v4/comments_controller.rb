# frozen_string_literal: true

module Api
  module V4
    class CommentsController < ApplicationController
      def index
        @hcb_code = authorize HcbCode.find_by_public_id(params[:transaction_id]), :show?
        @comments = @hcb_code.comments.includes(:user).order(created_at: :asc)
        @comments = @comments.not_admin_only unless current_user.admin?
      end

    end
  end
end
