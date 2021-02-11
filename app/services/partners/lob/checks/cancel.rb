module Partners
  module Lob
    module Checks
      class Cancel
        include ::Partners::Lob::Shared

        def initialize(id:)
          @id = id
        end

        def run
          @run ||= client.checks.destroy(@id)
        end
      end
    end
  end
end
