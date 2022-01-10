# frozen_string_literal: true

module Shared
  module Selenium
    module LoginToSvb

      private

      SLEEP_DURATION = Rails.env.development? ? 2 : 1

      def login_to_svb!
        # Go to auth url
        driver.navigate.to(auth_url)

        sleep SLEEP_DURATION

        # Click accept cookies modal
        begin
          el = driver.find_element(id: "accept-cookies")
          el.click
        rescue ::Selenium::WebDriver::Error::NoSuchElementError
        end

        # Username
        sleep SLEEP_DURATION
        el = driver.find_element(id: "userId")
        el.send_keys(username)

        # Password
        sleep SLEEP_DURATION
        el = driver.find_element(id: "userPassword")
        el.send_keys(password)

        # Login
        sleep SLEEP_DURATION * 2
        el = driver.find_element(id: "loginButton")
        el.click

        # Multifactor Authentication (if needed)
        handle_challenge_questions

        # ===== SVB MFA LOGIN (unused at the moment) =====
        # Make mfa request (to track and store code to be received)
        # make_mfa_request

        # # Click 'text me'
        # handle_click_text_me("Bank Automation")

        # # Fill mfa code
        # handle_fill_mfa_code
        # ================================================

        # Wait for homepage
        wait_for_homepage
      end

      def auth_url
        "https://www.svbconnect.com/auth"
      end

      def banking_url
        "https://banking.svbconnect.com"
      end

      def mfa_request
        @mfa_request ||= ::MfaRequestService::Create.new.run
      end

      def make_mfa_request
        mfa_request
      end

      def driver
        if Rails.env.development?
          @driver ||= ::Selenium::WebDriver.for :remote, url: "http://host.docker.internal:9515"
        else
          @driver ||= ::Selenium::WebDriver.for :chrome
        end
      end

      def username
        Rails.application.credentials.svb[:username]
      end

      def password
        Rails.application.credentials.svb[:password]
      end

      def challenge_answer_for(question)
        key = ("challenge_answer_" + question).to_sym
        Rails.application.credentials.svb[key]
      end

      def handle_challenge_questions
        begin
          # Wait until element is found... if element was not found, there are
          # no Challenge Questions and it will timeout (error raised)
          wait = ::Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
          wait.until { driver.find_element(id: "enteredChallengePhraseResponse") }

          # Element was found!

          sleep SLEEP_DURATION
          el = driver.find_element(id: "enteredChallengePhraseResponse")

          # Get question from form label
          question = driver.find_element(class: "svb-modal-confirm-identity-label-container").text

          # Attempt to match the question to a saved answer
          answer = challenge_answer_for("actor") if question.include?("Who is your favorite actor or musician?")
          answer = challenge_answer_for("hobby") if question.include?("What is your favorite hobby?")
          answer = challenge_answer_for("dessert") if question.include?("What is your favorite dessert?")

          # Error if we can't find an answer
          if answer.nil?
            Airbrake.notify("SVB Login, security challenge question without answer: #{question}")
          end

          # Fill in answer
          el.send_keys(answer)

          # Submit
          sleep SLEEP_DURATION * 2
          el = driver.find_element(class: "svb-confirm-identity-button")
          el.click

          # "Will you use this device to log in to Online Banking regularly?" defaults to "Yes"
          # Click continue to online banking button
          begin
            sleep SLEEP_DURATION
            el = driver.find_element(class: "svb-continue-button")
            el.click
          rescue ::Selenium::WebDriver::Error::NoSuchElementError
          end
        rescue
        end
      end

      def handle_click_text_me(phone_name)
        begin
          # Wait
          wait = ::Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
          wait.until { driver.find_element(:xpath, '//p[text()[.="unreachable at any of the above numbers" or contains(.,"unreachable at any of the above")]]') }
        rescue ::Selenium::WebDriver::Error::TimeoutError
          # Login to SVB account was unsucessful. Attempt to collect errors and report to Airbrake
          errors = driver.find_elements(:xpath, "//ul[contains(@class, 'svb-errors-list')]").map { |el| el.attribute("textContent").strip }.reject { |inner_html| inner_html.blank? }
          Airbrake.notify("Error while logging into '#{username}' SVB account. (#{errors.join(" ")})")
        end

        els = driver.find_elements(:xpath, '//div[@data-svb-class="svb-phone-number-container"]')
        els.each do |el|
          text = el.text
          name = text.split("\n")[0]

          # Identify correct phone number (in case of multiple) to send mfa to
          next unless name == phone_name

          sleep SLEEP_DURATION
          driver.action.move_to(el).perform
          sleep SLEEP_DURATION

          a = el.find_element(:xpath, 'div[@data-svb-class="svb-actions-wrapper"]/div/a')
          a.click
        end
      end

      def handle_fill_mfa_code
        # Wait
        wait = ::Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
        wait.until { driver.find_element(:xpath, '//input[@class="svb-data-input svb-enter-authenticate-code-container-input-code"]') }

        # Fill mfa code
        loop do
          sleep SLEEP_DURATION
          puts "waiting for code"

          next unless mfa_request.reload.received?

          # Code received
          # Fill code
          el = driver.find_element(:xpath, '//input[@class="svb-data-input svb-enter-authenticate-code-container-input-code"]')
          el.send_keys(mfa_request.mfa_code.code)

          # Confirm transfer
          el = driver.find_element(:xpath, "//button[contains(concat(' ', normalize-space(@class),' '),' svb-enter-authenticate-code-authenticate ')]")
          el.click

          break
        end
      end

      def handle_continue_to_online_banking
        # Wait
        wait = ::Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
        wait.until { driver.find_element(:xpath, "//button[contains(concat(' ', normalize-space(@class),' '),' svb-continue-button ')]") }

        # Confirm transfer
        el = driver.find_element(:xpath, "//button[contains(concat(' ', normalize-space(@class),' '),' svb-continue-button ')]")
        el.click
      end

      def wait_for_homepage
        wait = ::Selenium::WebDriver::Wait.new(timeout: 65)
        wait.until { driver.find_element(:xpath, '//h1[text()="Account Watch"]') }
      end

      # handy methods
      # driver.action.move_to(el).click(el).perform
      # driver.execute_script("arguments[0].click();", a)
      # driver.navigate.to(banking_url)

    end
  end
end
