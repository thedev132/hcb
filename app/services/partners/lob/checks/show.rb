module Partners
  module Lob
    module Checks
      class Show
        include ::Partners::Lob::Shared

        def initialize(id:)
          @id = id
        end

        def run
          client.checks.find(@id)
        end
      end
    end
  end
end
