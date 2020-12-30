module FeeReimbursementService
  class Nightly
    def run
      # 1. begin by navigating
      login_to_svb!

      FeeReimbursement.unprocessed.each do |fee_reimbursement|
        raise ArgumentError, "must be an unprocessed fee reimbursement only" unless fee_reimbursement.unprocessed?

        # Go to auth url
        driver.navigate.to(transfers_url)

        begin
          # Wait until you see the transfer page
          wait = Selenium::WebDriver::Wait.new(timeout: 10) # wait 5 seconds
          wait.until { driver.find_element(:xpath, '//h1[text()="Make a Transfer"]') }
        rescue => e
          Airbrake.notify(driver.inspect)
          Airbrake.notify(driver.page_source)

          raise e
        end

        # Configure the transfer
        sleep 1
        el = driver.find_element(:xpath, '//select[@name="fromAccountId"]/child::option[contains(text(), "FS Operating")]')
        el.click

        sleep 1
        el = driver.find_element(:xpath, '//select[@name="toAccountId"]/child::option[contains(text(), "FS Main")]')
        el.click

        sleep 1
        el = driver.find_element(:xpath, '//input[@name="transferAmountStr"]')
        el.send_keys("#{fee_reimbursement.amount.to_f / 100}")

        sleep 1
        el = driver.find_element(:xpath, '//textarea[@id="description-field"]')
        el.send_keys(fee_reimbursement.transaction_memo)

        # Submit the transfer
        sleep 1
        el = driver.find_element(:xpath, '//button[@type="submit"]')
        el.click

        # Wait for confirmation
        wait = Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
        wait.until { driver.find_element(:xpath, '//button[text()="Confirm Transfer"]') }

        # Confirm transfer
        sleep 1
        el = driver.find_element(:xpath, '//button[text()="Confirm Transfer"]')
        el.click

        # Wait for final confirmation
        wait = Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
        wait.until { driver.find_element(:xpath, '//h2[text()="Confirmation"]') }

        sleep 1

        fee_reimbursement.update_column(:processed_at, Time.now)

        sleep 10
      end

      driver.quit
    end

    private

    def fee_reimbursement
      @fee_reimbursement ||= FeeReimbursement.find(@fee_reimbursement_id)
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

      # Potentially handle challenge question - otherwise continue
      begin
        handle_challenge_question
      rescue Selenium::WebDriver::Error::TimeoutError => e
      end
    end

    def auth_url
      "https://www.svbconnect.com/auth"
    end

    def transfers_url
      "https://www.svbconnect.com/booktransfer/bookTransfer.do?cmdBookTransfer=1&mode=new"
    end

    def driver
      @driver ||= Selenium::WebDriver.for :chrome
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
      wait = Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
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
