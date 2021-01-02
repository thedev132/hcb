module Shared
  module Selenium
    module TransferFromFsMainToFsOperating
      private

      def transfer_from_fs_main_to_fs_operating!(amount_cents:, memo:)
        amount = amount_cents / 100.0

        # Go to transfer url
        driver.navigate.to(transfers_url)

        begin
          # Wait until you see the transfer page
          wait = ::Selenium::WebDriver::Wait.new(timeout: 10) # wait 5 seconds
          wait.until { driver.find_element(:xpath, '//h1[text()="Make a Transfer"]') }
        rescue => e
          Airbrake.notify(driver.inspect)
          Airbrake.notify(driver.page_source)

          raise e
        end

        # Configure the transfer
        sleep 1
        el = driver.find_element(:xpath, '//select[@name="fromAccountId"]/child::option[contains(text(), "FS Main")]')
        el.click

        sleep 1
        el = driver.find_element(:xpath, '//select[@name="toAccountId"]/child::option[contains(text(), "FS Operating")]')
        el.click

        sleep 1
        el = driver.find_element(:xpath, '//input[@name="transferAmountStr"]')
        el.send_keys("#{amount}")

        sleep 1
        el = driver.find_element(:xpath, '//textarea[@id="description-field"]')
        el.send_keys(memo)

        # Submit the transfer
        sleep 1
        el = driver.find_element(:xpath, '//button[@type="submit"]')
        el.click

        # Wait for confirmation
        wait = ::Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
        wait.until { driver.find_element(:xpath, '//button[text()="Confirm Transfer"]') }

        # Confirm transfer
        sleep 1
        el = driver.find_element(:xpath, '//button[text()="Confirm Transfer"]')
        el.click

        # Wait for final confirmation
        wait = ::Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
        wait.until { driver.find_element(:xpath, '//h2[text()="Confirmation"]') }

        sleep 1
      end

      def transfers_url
        "https://www.svbconnect.com/booktransfer/bookTransfer.do?cmdBookTransfer=1&mode=new"
      end
    end
  end
end
