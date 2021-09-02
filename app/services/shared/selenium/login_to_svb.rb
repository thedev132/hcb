# frozen_string_literal: true

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

        # # Potentially handle challenge question - otherwise continue
        # begin
        #   handle_challenge_question
        # rescue ::Selenium::WebDriver::Error::TimeoutError => e
        # end

        sleep 1

        selenium_session = ::SeleniumSession.active.last

        raise ArgumentError, "No active selenium sessions" unless selenium_session

        # Set logged in cookie
        # https://stackoverflow.com/questions/28187331/set-cookie-using-watir-webdriver-or-selenium/28277564
        #driver.cookies.add("SVB_OLB_TL_COOKIE","3b45dfb9-91b0-4f00-b967-160600e2fd4d", { domain: "*.svbconnect.com" })
        cookies = selenium_session.cookies
        cookies.each do |key, value|
          if cookie_names.include?(key) # only add for a specific list of cookies
            driver.manage.add_cookie(name: key, value: value, path: "/", domain: "svbconnect.com")
          end
        end

        sleep 1

        driver.navigate.to(banking_url)

        begin
          # Wait until you see the transfer page
          wait = ::Selenium::WebDriver::Wait.new(timeout: 10) # wait 10 seconds
          wait.until { driver.find_element(:xpath, "//div[contains(concat(' ', normalize-space(@class),' '),' account-number ')]") }
        rescue => e
          Airbrake.notify(driver.inspect)
          Airbrake.notify(driver.page_source)

          selenium_session.mark_expired!

          raise ArgumentError, "Login failed"
        end
      end

      def cookie_names
        [
          "TL1M4Djm3mCaVQc_",
          "_WL_AUTHCOOKIE_OnlineSiliconDummy",
          "wfx_unq",
          "SVB_OLB_TL_COOKIE",
          "OnlineSiliconDummy",
          "QuantumMetricSessionID",
          "QuantumMetricUserID"
        ]
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

      def banking_url
        "https://banking.svbconnect.com"
      end
    end
  end
end
