# frozen_string_literal: true

module Api
  class V1Controller < Api::ApplicationController
    def index
      render json: {}
    end
  end
end
