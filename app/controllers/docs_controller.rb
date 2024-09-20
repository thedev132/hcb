# frozen_string_literal: true

class DocsController < ActionController::Base
  skip_before_action :verify_authenticity_token

  include Swagger::Blocks

  swagger_component do
    security_scheme :ApiKeyAuth do
      key :type, :apiKey
      key :in, :header
      key :name, :Authorization
    end
  end

  swagger_root do
    key :openapi, "3.0.0"
  end

  SWAGGERED_CLASSES = [
    ApplicationDocumentation,
    self
  ].freeze

  def swagger
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end

end
