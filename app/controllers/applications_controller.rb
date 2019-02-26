class ApplicationsController < ApplicationController
  include ApplicationsHelper
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user

  # This pigsty was created from
  # https://stackoverflow.com/a/51110844
  before_action do
    ActiveStorage::Current.host = request.base_url
  end

  def apply
  end

  def submit
    app = Airtable::Record.new({})
    applications.create(app)

    event = Airtable::Record.new({
      "Event Name": params[:application][:event_name],
      "Website": params[:application][:website],
      "Tell us about your event": params[:application][:about_event],
      "Tell us about your history": params[:application][:about_history],
      "Have you already opened sign-ups for the event?": params[:application][:opened_sign_ups].to_i == 0 ? "No" : "Yes",
      "Expected Attendees": params[:application][:expected_attendees].to_i,
      "Application": [ app.id ],
      "Expected Budget": params[:application][:expected_budget].to_i
    })
    events.create(event)

    team = Airtable::Record.new(
      "Has your team organized events before? If so, which ones, what were the budgets, and how many people came?": params[:application][:organizer_history],
      "Application": [ app.id ]
    )
    teams.create(team)

    params[:application][:team_members].each do |key, member_params|
      team_member = Airtable::Record.new({
        "Name (First / Last)": member_params[:name],
        "Email": member_params[:email],
        "Phone": member_params[:phone_number],
        "Date of birth": member_params[:birthdate],
        "Title": member_params[:title],
        "Identification document": [ { url: to_blob(member_params[:identification]).service_url } ],
        "Team": [ team.id ]
      })
      team_members.create(team_member)

      if Date.today - 18.years <= Date.parse(member_params[:birthdate])

        parent = Airtable::Record.new({
          "Name (First / Last)": member_params[:parent_name],
          "Child": [ team_member.id ],
          "Email": member_params[:parent_email],
          "Phone": member_params[:parent_phone_number],
          "Date of birth": member_params[:parent_birthdate],
          "Identification document": [ { url: to_blob(member_params[:parent_identification]).service_url } ],
        })
        parents.create(parent)
    end
  end

  render :submit
  end

  private

  def to_blob(file)
    ActiveStorage::Blob.build_after_upload(
      io: file,
      filename: file.original_filename,
      content_type: file.content_type
    )
  end
end
