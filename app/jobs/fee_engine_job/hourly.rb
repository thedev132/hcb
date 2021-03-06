module FeeEngineJob
  class Hourly < ApplicationJob
    def perform
      ::FeeEngine::Hourly.new.run
    end
  end
end
