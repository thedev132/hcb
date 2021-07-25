# frozen_string_literal: true

module ApplicationsHelper
  def applications
    @applications ||= client.table(Rails.application.credentials.airtable[:base], "Applications")
  end

  def events
    @events ||= @client.table(Rails.application.credentials.airtable[:base], "Events")
  end

  def teams
    @teams ||= @client.table(Rails.application.credentials.airtable[:base], "Teams")
  end

  def team_members
    @team_members ||= @client.table(Rails.application.credentials.airtable[:base], "Team Members")
  end

  def parents
    @parents ||= @client.table(Rails.application.credentials.airtable[:base], "Parents")
  end

  private

  def client
    @client ||= Airtable::Client.new(Rails.application.credentials.airtable[:key])
  end
end
