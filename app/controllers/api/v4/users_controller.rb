# frozen_string_literal: true

module Api
  module V4
    class UsersController < ApplicationController
      def show
        @user = authorize current_user
      end

    end
  end
end
