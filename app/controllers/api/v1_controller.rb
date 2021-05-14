# frozen_string_literal: true

module Api
  class V1Controller < Api::ApplicationController
    def index
      contract = Api::V1::IndexContract.new.call(params.permit!.to_h)

      render json: Api::V1::IndexSerializer.new.run
    end
  end
end
