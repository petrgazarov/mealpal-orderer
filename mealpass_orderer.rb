require 'rubygems'
require 'selenium-webdriver'
require 'pry'

class MealpassOrderer
  def self.run
    new.run
  end

  def initialize
    @driver = Selenium::WebDriver.for :chrome
    @wait = Selenium::WebDriver::Wait.new(:timeout => 15)
  end

  def run
    login

    (driver.close; return) if meal_reserved?

    enter_address


    num_choices = driver.find_elements(:css, '.meal').length
    pick_number = (0...num_choices).to_a.sample

    driver.find_elements(:css, '.meal')[pick_number].click

    wait.until do
      driver
        .find_elements(:css, '.meal')[pick_number]
        .find_element(:xpath, "//span[contains(., 'PICKUP TIME')]").displayed?
    end

    driver
      .find_elements(:css, '.meal')[pick_number]
      .find_element(:xpath, "//span[text()='PICKUP TIME']").click

    driver.find_element(:xpath, "//span[text()='PICKUP TIME']").click

    # driver.find_element(:xpath,"//input[@value='SUBMIT']").click
    # driver.find_element(:xpath,"//input[@value='PICKUP TIME']").click
    # driver.find_element(:xpath,"//input[@value='RESERVE NOW']").click

    driver.close
  end

  attr_reader :driver, :wait

  private

  def login
    driver.get "https://mealpass.com/login"
    wait.until { driver.find_element(:name, "email").displayed? }

    driver.find_element(:name, "email").send_keys(ENV['MEALPASS_EMAIL'])
    driver.find_element(:name, "password").send_keys(ENV['MEALPASS_PASSWORD'])

    driver.find_element(:xpath, '//button[contains(., "Log in")]').click

    wait.until { driver.title.downcase == 'mealpass | portal' }
  end

  def meal_reserved?
    driver.page_source.include? 'Your meal is reserved'
  end

  def enter_address
    wait.until { driver.find_element(:xpath, "//input[@placeholder='Search Location ...']").displayed? }
    driver
      .find_element(:xpath, "//input[@placeholder='Search Location ...']")
      .send_keys('22 West 19th Street, New York, NY, United States')

    driver.action.send_keys(:enter).perform

    wait.until { driver.find_element(:css, '.lazy-loading').displayed? }
  end
end

MealpassOrderer.run
