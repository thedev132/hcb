# frozen_string_literal: true

module Shared
  module Selenium
    module LoginToSvb

      private

      # wfx_unq VJTzIb9cmaNKiUwt
      # TL1M4Djm3mCaVQc_    v1B9BNgw__lw-, v1BNBNgw__HGM, v1CdBNgw__hLm, v1BNBNgw__HGM
      # _WL_AUTHCOOKIE_OnlineSiliconDummy     gMDHJ4qNZaLl3lfud9bu, 7pUldIEdniuQTFGyTSgL
      # ADRUM_BT1 NIXED
      # ADRUM_BTs NIXED
      # ADRUM_BTa
      # OnlineSiliconDummy is different
      # wfx_uniq is different

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

      def cookie_values
        [
          "v1B9BNgw__lw-",
          "7pUldIEdniuQTFGyTSgL",
          "VJTzIb9cmaNKiUwt",
          "1ba188aa-5e8f-403e-9816-cf00cc8c06d3",
          "Sz72YuglLACPYKB7E2MWXEh80MDCxKSIMhfLtDjn1S8V3dBcMC75!-382805785",
          "d4cf9c88fe0f37e9f0bb77d25b219873",
          "0f78aa556a0f941a19257a55b8b45dea"
        ]
      end

      def banking_url
        "https://banking.svbconnect.com"
      end

      def transfers_url
        "https://www.svbconnect.com/booktransfer/bookTransfer.do?cmdBookTransfer=1&mode=new"
      end

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

        # Set logged in cookie
        # https://stackoverflow.com/questions/28187331/set-cookie-using-watir-webdriver-or-selenium/28277564
        #driver.cookies.add("SVB_OLB_TL_COOKIE","3b45dfb9-91b0-4f00-b967-160600e2fd4d", { domain: "*.svbconnect.com" })
        
        driver.manage.add_cookie(name: cookie_names[0], value: cookie_values[0], path: "/", domain: "svbconnect.com")
        driver.manage.add_cookie(name: cookie_names[1], value: cookie_values[1], path: "/", domain: "svbconnect.com")
        driver.manage.add_cookie(name: cookie_names[2], value: cookie_values[2], path: "/", domain: "svbconnect.com")
        driver.manage.add_cookie(name: cookie_names[3], value: cookie_values[3], path: "/", domain: "svbconnect.com")
        driver.manage.add_cookie(name: cookie_names[4], value: cookie_values[4], path: "/", domain: "svbconnect.com")
        driver.manage.add_cookie(name: cookie_names[5], value: cookie_values[5], path: "/", domain: "svbconnect.com")
        driver.manage.add_cookie(name: cookie_names[6], value: cookie_values[6], path: "/", domain: "svbconnect.com")

        sleep 1

        driver.navigate.to(banking_url)

        byebug
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
