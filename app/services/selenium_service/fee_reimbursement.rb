module SeleniumService
  class FeeReimbursement
    def initialize(memo:, amount:)
      @memo = memo
      @amount = amount
    end

    def run
      # Go to auth url
      driver.navigate.to(auth_url)

      # Click accept cookies modal
      el = driver.find_element(id: "accept-cookies")
      el.click

      # Username
      el = driver.find_element(id: "userId")
      el.send_keys(username)

      # Password
      el = driver.find_element(id: "userPassword")
      el.send_keys(password)

      # Login
      el = driver.find_element(id: "loginButton")
      el.click

      # Potentially handle challenge question - otherwise continue
      begin
        handle_challenge_question
      rescue Selenium::WebDriver::Error::TimeoutError => e
      end

      wait = Selenium::WebDriver::Wait.new(timeout: 5) # wait 5 seconds

      # Go to auth url
      driver.navigate.to(transfers_url)

      # Wait until you see the transfer page
      wait = Selenium::WebDriver::Wait.new(timeout: 65) # wait 5 seconds
      wait.until { driver.find_element(:xpath, '//h1[text()="Make a Transfer"]') }

      # Configure the transfer
      el = driver.find_element(:xpath, '//select[@name="fromAccountId"]/child::option[contains(text(), "FS Operating")]')
      el.click
      el = driver.find_element(:xpath, '//select[@name="toAccountId"]/child::option[contains(text(), "FS Main")]')
      el.click
      el = driver.find_element(:xpath, '//input[@name="transferAmountStr"]')
      el.send_keys("#{@amount}")
      el = driver.find_element(:xpath, '//textarea[@id="description-field"]')
      el.send_keys(@memo)

      # Submit the transfer
      el = driver.find_element(:xpath, '//button[@type="submit"]')
      el.click

      # Wait for confirmation
      wait = Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
      wait.until { driver.find_element(:xpath, '//button[text()="Confirm Transfer"]') }

      # Confirm transfer
      el = driver.find_element(:xpath, '//button[text()="Confirm Transfer"]')
      el.click

      # Wait for final confirmation
      wait = Selenium::WebDriver::Wait.new(timeout: 65) # wait 65 seconds
      wait.until { driver.find_element(:xpath, '//h2[text()="Confirmation"]') }

      driver.quit
    end

    private

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
      el = driver.find_element(id: "enteredChallengePhraseResponse")
      el.send_keys(challenge_answer)
      
      # Submit answer
      el = driver.find_element(class: "svb-confirm-identity-button")
      el.click

      # Continue on identify confirmed
      el = driver.find_element(class: "svb-continue-button")
      el.click
    end
  end
end
