# frozen_string_literal: true

module TransactionEngineJob
  module FriendlyMemo
    class Nightly < ApplicationJob
      def perform
        ::TransactionEngine::FriendlyMemoService::Nightly.new.run
      end
    end
  end
end
