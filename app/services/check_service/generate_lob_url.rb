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
      @remote_check ||= LobService.instance.client.checks.find(lob_id)
    end

    def lob_id
      @check.lob_id
    end
  end
end
