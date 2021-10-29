# frozen_string_literal: true

module Api
    module V1
      class ConnectStartSerializer
        def initialize(partnered_signup:)
          @partnered_signup = partnered_signup
        end
  
        def run
          {
            data: data
          }
        end
  
        private
  
        def data
          {
            redirect_url: @partnered_signup.redirect_url,
            id: @partnered_signup.public_id,
            connect_url: @partnered_signup.continue_url
          }
        end
      end
    end
  end
