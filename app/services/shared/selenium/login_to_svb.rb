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

        # Make mfa request (to track and store code to be received)
        make_mfa_request

        # Click 'text me'
        handle_click_text_me("Bank Automation")

        # Fill mfa code
        handle_fill_mfa_code

        # Continue to online banking
        handle_continue_to_online_banking

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
        @driver ||= ::Selenium::WebDriver.for :chrome
      end

      def username
        Rails.application.credentials.svb[:username]
      end

      def password
        Rails.application.credentials.svb[:password]
      end

      def handle_click_text_me(phone_name)
        begin
        # Wait
          wait = ::Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
          wait.until { driver.find_element(:xpath, '//p[text()[.="unreachable at any of the above numbers" or contains(.,"unreachable at any of the above")]]') }
        rescue ::Selenium::WebDriver::Error::TimeoutError
          # Login to SVB account was unsucessful. Attempt to collect errors and report to Airbrake
          errors = driver.find_elements(:xpath, "//ul[contains(@class, 'svb-errors-list')]").map { |el| el.attribute("innerHTML") }.select { |innerHtml| !innerHtml.blank? }
          Airbrake.notify("Error while logging into '#{username}' SVB account. (#{errors.join(" ")})")
        end

        els = driver.find_elements(:xpath, '//div[@data-svb-class="svb-phone-number-container"]')
        els.each do |el|
          text = el.text
          name = text.split("\n")[0]

          # Identify correct phone number (in case of multiple) to send mfa to
          if name == phone_name
            sleep 1
            driver.action.move_to(el).perform
            sleep 1

            a = el.find_element(:xpath, 'div[@data-svb-class="svb-actions-wrapper"]/div/a')
            a.click
          end
        end
      end

      def handle_fill_mfa_code
        # Wait
        wait = ::Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
        wait.until { driver.find_element(:xpath, '//input[@class="svb-data-input svb-enter-authenticate-code-container-input-code"]') }

        # Fill mfa code
        loop do
          sleep 1
          puts "waiting for code"

          # Code received
          if mfa_request.reload.received?
            # Fill code
            el = driver.find_element(:xpath, '//input[@class="svb-data-input svb-enter-authenticate-code-container-input-code"]')
            el.send_keys(mfa_request.mfa_code.code)

            # Confirm transfer
            el = driver.find_element(:xpath, "//button[contains(concat(' ', normalize-space(@class),' '),' svb-enter-authenticate-code-authenticate ')]")
            el.click

            break
          end
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
