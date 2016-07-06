require 'rubygems'
require 'selenium-webdriver'
require 'pry'

driver = Selenium::WebDriver.for :chrome
wait = Selenium::WebDriver::Wait.new(:timeout => 15)

driver.get "https://mealpass.com/login"
wait

wait.until { driver.find_element(:name, "email").displayed? }

driver.find_element(:name, "email").send_keys("petrgazarov@gmail.com")
driver.find_element(:name, "password").send_keys("n7T1351#2%f@")

driver.find_element(:link_text, 'Log in').click
driver.find_element(:xpath,"//input[@value='Log in']").click

driver.find_element(:xpath,"//input[@value='SUBMIT']").click
driver.find_element(:xpath,"//input[@value='PICKUP TIME']").click
driver.find_element(:xpath,"//input[@value='RESERVE NOW']").click

