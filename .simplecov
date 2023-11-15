# frozen_string_literal: true

SimpleCov.start "rails" do
  add_filter "/app/documentations/"

  add_group "Services", "app/services"
  add_group "Policies", "app/policies"
end
