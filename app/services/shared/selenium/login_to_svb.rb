module Shared
  module Selenium
    module LoginToSvb

      private

      def login_to_svb!
        # Go to auth url
        driver.navigate.to(auth_url)

        sleep 1

        # Click accept cookies modal
        begin
          el = driver.find_element(id: "accept-cookies")
          el.click
        rescue
        end

        # Username
        sleep 1
        el = driver.find_element(id: "userId")
        el.send_keys(username)

        # Password
        sleep 1
        el = driver.find_element(id: "userPassword")
        el.send_keys(password)

        # Login
        sleep 1
        el = driver.find_element(id: "loginButton")
        el.click

        # Potentially handle challenge question - otherwise continue
        begin
          handle_challenge_question
        rescue ::Selenium::WebDriver::Error::TimeoutError => e
        end
      end

      def auth_url
        "https://www.svbconnect.com/auth"
      end

      def driver
        @driver ||= ::Selenium::WebDriver.for :chrome
      end

      def username
        Rails.application.credentials.svb[:username]
      end

      def password
        Rails.application.credentials.svb[:password]
      end

      def challenge_answer_architect
        Rails.application.credentials.svb[:challenge_answer_architect]
      end

      def challenge_answer_car
        Rails.application.credentials.svb[:challenge_answer_car]
      end

      def challenge_answer_place
        Rails.application.credentials.svb[:challenge_answer_place]
      end

      def handle_challenge_question
        # Wait
        wait = ::Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
        wait.until { driver.find_element(id: "enteredChallengePhraseResponse") }

        # Handle challenge answer
        el = driver.find_element(class: "svb-modal-confirm-identity-label-container")
        challenge_answer = nil
        challenge_answer = challenge_answer_architect if el.text.downcase.include?("architect")
        challenge_answer = challenge_answer_car if el.text.downcase.include?("car")
        challenge_answer = challenge_answer_place if el.text.downcase.include?("visit")

        # Challenge question
        sleep 1
        el = driver.find_element(id: "enteredChallengePhraseResponse")
        el.send_keys(challenge_answer)
        
        # Submit answer
        sleep 1
        el = driver.find_element(class: "svb-confirm-identity-button")
        el.click

        # Continue on identify confirmed
        sleep 1
        el = driver.find_element(class: "svb-continue-button")
        el.click

        sleep 10
      end
    end
  end
end
