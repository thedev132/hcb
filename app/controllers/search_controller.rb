# frozen_string_literal: true

class SearchController < ApplicationController
  skip_after_action :verify_authorized # do not force pundit
  before_action :signed_in_admin # This feature is only available to admins for the time being
  # GET /search
  def index
    begin
      query = SearchService::Parser.new(params[:query]).run
      results = SearchService::Authorizer.new(
        SearchService::Engine.new(query, current_user).run,
        current_user
      ).run

      render json: SearchService::Formatter.new(results).run
    rescue Errors::ValidationError => e
      # Handle any validation errors
      render json: { error: e.message }
    end
  end

end
