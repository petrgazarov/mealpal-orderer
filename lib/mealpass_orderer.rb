require 'rubygems'
require 'selenium-webdriver'

class MealpassOrderer

  NUM_RETRIES = 3

  def self.run
    new.run
  end

  def initialize
    @driver = Selenium::WebDriver.for :chrome
    @wait = Selenium::WebDriver::Wait.new(:timeout => 15)
    @retries = 0
  end

  def run
    begin
      driver.get "https://mealpass.com/login"

      login unless logged_in?

      wait.until { driver.title.downcase == 'mealpass | portal' }

      raise 'Kitchen closed' if kitchen_closed?

      rate_meal if rate_meal_required?

      raise 'Meal already reserved' if meal_reserved?

      enter_address

      select_meal

    rescue Exception => e
      log_error(e)

      self.retries += 1
      retry unless used_all_retry_attempts
    ensure
      driver.close
    end
  end

  attr_accessor :retries

  private

  def login
    wait.until { driver.find_element(:name, "email").displayed? }

    driver.find_element(:name, "email").send_keys(ENV['MEALPASS_EMAIL'])
    driver.find_element(:name, "password").send_keys(ENV['MEALPASS_PASSWORD'])

    driver.find_element(:xpath, '//button[contains(., "Log in")]').click
  end

  def logged_in?
    driver.manage.cookie_named('isLoggedIn')
  end

  def meal_reserved?
    driver.page_source.include? 'Your meal is reserved'
  end

  def kitchen_closed?
    driver.page_source.include? 'The kitchen is closed'
  end

  def rate_meal_required?
    driver.page_source.include? 'Rate your meal!'
  end

  def rate_meal
    wait.until { driver.find_elements(:xpath, "//span[contains(@class, 'star')]")[3].displayed? }
    # rate as a "4" (good)
    driver.find_elements(:xpath, "//span[contains(@class, 'star')]")[3].click
    # rate as a medium size portion
    driver.find_elements(:xpath, "//span[contains(@class, 'portion ng-scope')]")[1].click

    driver.find_element(:xpath, '//span[contains(., "SUBMIT")]').click
  end

  def enter_address
    wait.until { driver.find_element(:xpath, "//input[@placeholder='Search Location ...']").displayed? }
    driver
      .find_element(:xpath, "//input[@placeholder='Search Location ...']")
      .send_keys('22 West 19th Street, New York, NY, United States')

    driver.action.send_keys(:enter).perform

    wait.until { driver.find_element(:css, '.lazy-loading').displayed? }
  end

  def select_meal
    num_choices = driver.find_elements(:css, '.meal').length
    pick_number = (0...num_choices).to_a.sample

    wait.until { driver.find_elements(:css, '.meal')[pick_number].displayed? }

    driver
      .find_elements(:css, '.meal')[pick_number]
      .find_elements(:css, '.name')[1]
      .click

    wait.until do
      driver
        .find_elements(:css, '.meal')[pick_number]
        .find_element(:css, '.mp-pickup-button')
        .displayed?
    end

    driver
      .find_elements(:css, '.meal')[pick_number]
      .find_element(:css, '.mp-pickup-button')
      .click

    wait.until do
      driver
        .find_elements(:css, '.meal')[pick_number].find_element(:css, "li")
        .displayed?
    end

    driver.find_elements(:css, '.meal')[pick_number].find_element(:css, "li").click

    driver.find_elements(:css, '.meal')[pick_number].find_element(:css, '.mp-reserve-button').click
  end

  def log_error(e)
    error_log_entry = "\n===========================\n#{Time.now}\n#{e}"
    File.open('error_log.log', 'a') { |file| file << error_log_entry }
    puts e # REMOVE ME
  end

  def used_all_retry_attempts
    retries == NUM_RETRIES
  end

  attr_reader :driver, :wait
end
