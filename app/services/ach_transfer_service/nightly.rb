module AchTransferService
  class Nightly
    def run
      # mark
      AchTransfer.in_transit.each do |ach_transfer|
        # 1. check if it has cleared the pending transaction
        # 2. if it is has, then mark deposited
      end
    end
  end
end
