require_relative '../lib/mealpass_orderer'
require 'pry'

CURRENT_DIR = File.expand_path(File.dirname(__FILE__))
CHROMEDRIVER_FN = File.join(File.absolute_path('..', CURRENT_DIR), "bin/chromedriver")
Selenium::WebDriver::Chrome.driver_path = CHROMEDRIVER_FN

MealpassOrderer.run
