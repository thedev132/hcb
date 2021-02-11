module CheckService
  class Nightly
    def run
      # process checks ready to be sent (check created on lob)
      Check.scheduled.where("send_date <= ?", Time.now.utc).each do |check|
        ::CheckService::Send.new(check_id: check.id).run
      end
    end
  end
end
