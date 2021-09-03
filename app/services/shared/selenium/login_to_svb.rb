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

        # Prep mfa request
        mfa_request = ::MfaRequestService::Create.new.run

        handle_click_text_me("Mobile")

        handle_fill_mfa_code
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

      def handle_click_text_me(phone_name)
        # Wait
        wait = ::Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
        wait.until { driver.find_element(:xpath, '//p[text()[.="unreachable at any of the above numbers" or contains(.,"unreachable at any of the above")]]') }

        els = driver.find_elements(:xpath, '//div[@data-svb-class="svb-phone-number-container"]')
        els.each do |el|

          text = el.text
          name = text.split("\n")[0]

          # Find 'Mobile' phone
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
        el = driver.find_element(:xpath, '//input[@class="svb-data-input svb-enter-authenticate-code-container-input-code"]')
        el.send_keys("123456")

        # Confirm transfer
        sleep 1
        el = driver.find_element(:xpath, "//button[contains(concat(' ', normalize-space(@class),' '),' svb-enter-authenticate-code-authenticate ')]")
        el.click
      end

      # handy methods
      # driver.action.move_to(el).click(el).perform
      # driver.execute_script("arguments[0].click();", a)
      # driver.navigate.to(banking_url)

      def banking_url
        "https://banking.svbconnect.com"
      end
    end
  end
end
