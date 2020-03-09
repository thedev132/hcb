class ApiController < ApplicationController
  before_action :check_token
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user

  # find an event by slug
  def event_find
    # pull slug out from JSON
    slug = params[:slug]

    e = Event.find_by_slug(slug)

    # event not found
    if e == nil
      render json: { error: 'Not Found' }, status: 404
      return
    end

    render json: { 
      name: e.name,
      organizer_emails: e.users.pluck(:email),
      total_balance: e.balance / 100
    }
  end

  # create a spend only event
  def event_new
    expecting = ['name', 'organizer_emails']
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
        error: "Missing " + missing
      }, status: 400
      return
    end

    name = params[:name]
    organizer_emails = params[:organizer_emails]
    slug = params[:slug]

    if slug.nil? || slug.empty?
      # this is what FriendlyId uses to create slugs
      slug = ActiveSupport::Inflector.parameterize(name)
    end

    events = Event.all.map { |e| e.point_of_contact_id }

    # get most common POC
    point_of_contact_id = events.max_by {|i| events.count(i) }

    e = Event.new(
        name: name,
        start: Date.current,
        end: Date.current,
        address: 'N/A',
        sponsorship_fee: 0.07,
        expected_budget: 100.0,
        has_fiscal_sponsorship_document: false,
        point_of_contact_id: point_of_contact_id,
        is_spend_only: true,
    )

    if !e.save
      render json: { error: "Event couldn't be created!" + e.errors.full_messages }, status: 500
      return
    end

    organizer_emails.each do |email|
      OrganizerPositionInvite.create(
        sender: User.find(point_of_contact_id),
        event: e,
        email: email
      )
    end

    render json: { 
      name: e.name,
      is_spend_only: e.is_spend_only,
      slug: e.slug,
      organizer_emails: e.users.pluck(:email)
    }, status: 201
  end

  def disbursement_new
    expecting = ['source_event_slug', 'destination_event_slug', 'amount', 'name']
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
    if params[:token] != Rails.application.credentials.api_token
      render json: {error: 'Unauthorized'}, status: 401
      return
    end
  end
end