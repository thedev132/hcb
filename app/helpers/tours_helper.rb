# frozen_string_literal: true

module ToursHelper
  # Starts a tour for the given Tourable
  def start_tour(tourable, name)
    tour = tourable.tours.find_or_initialize_by(name: name)
    tour.update(active: true, step: 0)
  end

  # Renders the given tour to the UI
  def render_tour(tourable, name)
    tour = tourable.tours.find_by(name: name)
    if tour&.active
      @tour = tour
    end
  end

  # Renders a "Back to tour" button if there's an active tour
  def render_back_to_tour(tourable, name, url)
    if tourable.tours.find_by(name: name)&.active?
      @back_to_tour = url
    end
  end
end
