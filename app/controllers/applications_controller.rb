class ApplicationsController < ApplicationController
  include ApplicationsHelper
  skip_after_action :verify_authorized # do not force pundit
  skip_before_action :signed_in_user

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
      "Have you already opened sign-ups for the event?": params[:application][:opened_sign_ups] ? "No" : "Yes",
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
      birthdate = "#{member_params['birthdate(1i)']}-#{member_params['birthdate(2i)']}-#{member_params['birthdate(3i)']}"
      team_member = Airtable::Record.new({
        "Name (First / Last)": member_params[:name],
        "Email": member_params[:email],
        "Phone": member_params[:phone_number],
        "Date of birth": birthdate,
        "Title": member_params[:title],
        "Team": [ team.id ]
      })
      team_members.create(team_member)

      if Date.today - 18.years <= Date.parse(birthdate)
        parent_birthdate = "#{member_params['parent_birthdate(1i)']}-#{member_params['parent_birthdate(2i)']}-#{member_params['parent_birthdate(3i)']}"
        parent = Airtable::Record.new({
          "Name (First / Last)": member_params[:parent_name],
          "Child": [ team_member.id ],
          "Email": member_params[:parent_email],
          "Phone": member_params[:parent_phone_number],
          "Date of birth": parent_birthdate
        })
    end
  end

  render :submit
  end
end
