# frozen_string_literal: true

class ApiController < ApplicationController
  before_action :check_token
  before_action :set_params
  skip_before_action :verify_authenticity_token # do not use CSRF token checking for API routes
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user

  # find an event by slug
  def event_find
    # pull slug out from JSON
    slug = params[:slug]

    e = Event.find_by_slug(slug)

    # event not found
    if e.nil?
      render json: { error: "Not Found" }, status: 404
      return
    end

    render json: {
      name: e.name,
      organizer_emails: e.users.pluck(:email),
      total_balance: e.balance / 100
    }
  end

  def disbursement_new
    expecting = ["source_event_slug", "destination_event_slug", "amount", "name"]
    got = params.keys
    missing = []

    expecting.each do |e|
      if !got.include? e
        missing.push(e)
      end

      expecting.delete(e)
    end

    if missing.size > 0
      render json: {
        error: "Missing " + missing.to_s
      }, status: 400
      return
    end

    source_event_slug = params[:source_event_slug]
    destination_event_slug = params[:destination_event_slug]
    amount = params[:amount].to_f * 100
    name = params[:name]

    target_event = Event.find_by_slug(destination_event_slug)

    if !target_event
      render json: { error: "Couldn't find target event!" }, status: 404
      return
    end

    d = Disbursement.new(
      event: target_event,
      source_event: Event.find(source_event_slug),
      amount: amount,
      name: name
    )

    if !d.save
      render json: { error: "Disbursement couldn't be created!" + d.errors.full_messages }, status: 500
      return
    end

    render json: {
      source_event_slug: source_event_slug,
      destination_event_slug: destination_event_slug,
      amount: amount.to_f / 100,
      name: name
    }, status: 201
  end

  private

  def check_token
    attempt_api_token = request.headers["Authorization"]&.split(" ")&.last
    if attempt_api_token != Rails.application.credentials.api_token
      render json: { error: "Unauthorized" }, status: 401
      return
    end
  end

  def set_params
    @params = ActiveSupport::JSON.decode(request.body.read)
  end
end
