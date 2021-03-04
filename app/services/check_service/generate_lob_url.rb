module CheckService
  class GenerateLobUrl
    def initialize(check:)
      @check = check
    end

    def run
      remote_check["url"]
    end

    private

    def remote_check
      @remote_check ||= ::Partners::Lob::Checks::Show.new(id: lob_id).run
    end

    def lob_id
      @check.lob_id
    end
  end
end
