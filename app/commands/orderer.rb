require 'watir-webdriver'

class Orderer
  def self.run(user)
    new(user).run
  end

  def initialize(user:, todays_order_day:)
    @driver = Watir::Browser.new :phantomjs
    @wait = Watir::Wait
    @user = user
    @todays_order_day = todays_order_day

    driver.window.resize_to(1200, 1200)
  end

  def run
    begin
      log('Starting to order')

      # remove watir cookies
      delete_cookies

      visit_login_page

      login

      raise 'Kitchen closed' if kitchen_closed?

      rate_meal if rate_meal_required?

      raise 'Meal already reserved' if meal_reserved?

      enter_address

      select_meal

      record_success
      true

    rescue Exception => e
      log_error(e)
    ensure
      close_driver
    end
  end

  private

  def visit_login_page
    driver.goto "https://mealpass.com/login"

    wait.until { driver.text.include? "Log in to your MealPass account" }
  end

  def login
    driver.text_field(:name, "email").when_present.set(user.mealpass_email)
    driver.text_field(:name, "password").set(user.mealpass_password)

    driver.button(:text, "Log in").click

    wait.until { driver.text.include? "WHAT'S FOR LUNCH ?" }
  end

  def meal_reserved?
    driver.text.include? 'Your meal is reserved'
  end

  def kitchen_closed?
    driver.text.include? 'The kitchen is closed'
  end

  def rate_meal_required?
    driver.text.include? 'Rate your meal!'
  end

  def rate_meal
    # rate as a "4" (good)
    driver.spans(class_name: 'star')[3].click
    # rate as a medium size portion
    driver.spans(class_name: 'portion ng-scope')[1].click

    driver.button(:text, "SUBMIT").click
  end

  def enter_address
    driver
      .text_field { input(:placeholder => 'Search Location ...') }
      .set('22 West 19th Street, New York, NY, United States')

    driver.send_keys :enter
  end

  def select_meal
    wait.until { driver.spans(:css, '.meal').length && driver.spans(:css, '.meal').length > 0 }
    sleep 12

    num_choices = driver.spans(:css, '.meal').length
    num_choices = 20 if num_choices > 20
    picked_choice_num = nil

    num_choices.times do |choice_num|
      name =
        driver
          .spans(:css, '.meal')[choice_num]
          .img.attribute_value('alt')

      if todays_order_day.whitelist.split(', ').any? { |item| name.downcase.include?(item.downcase) }
        picked_choice_num = choice_num

        break
      end
    end

    begin
      unless picked_choice_num
        picked_choice_num = (0...num_choices).to_a.sample
      end

      meal_name =
        driver
          .spans(:css, '.meal')[picked_choice_num]
          .img.attribute_value('alt')

      restaurant_name =
        driver
          .spans(:css, '.meal')[picked_choice_num]
          .div(:css, '.restaurant')
          .div(:css, '.name')
          .text

      if todays_order_day.blacklist.split(', ').any? { |item| (meal_name + restaurant_name).downcase.include?(item.downcase) }
        log "item #{meal_name} in #{restaurant_name} restaurant blacklisted."

        raise ItemBlackListedError.new
      end

      driver
        .spans(:css, '.meal')[picked_choice_num]
        .div(:css, '.address').click

      driver
        .spans(:css, '.meal')[picked_choice_num]
        .button(class_name: 'mp-pickup-button').click

      driver
        .spans(:css, '.meal')[picked_choice_num]
        .ul(:class_name => 'pickupTimes-list')
        .lis.find { |li| li.text == '12:00pm-12:15pm' }
        .click

      driver
        .spans(:css, '.meal')[picked_choice_num]
        .button(text: 'RESERVE NOW').click

      wait.until { driver.text.include? 'Your meal is reserved!' }

      create_ordered_item(
        name: meal_name,
        restaurant_name: restaurant_name
      )
    rescue ItemBlackListedError
      picked_choice_num = nil

      retry
    end
  end

  def log(message)
    log_entry = "\n===========================\n#{Time.zone.now}\nuser_id: #{user.id}\n#{message}"

    File.open('log/log.log', 'a') { |file| file << log_entry }

    puts message
  end

  def delete_cookies
    driver.cookies.clear
  end

  def create_ordered_item(ordered_item_attributes)
    user.ordered_items.create!(
      ordered_item_attributes.merge(ordered_at: Time.zone.now)
    )
  end

  def record_success
    log("Ordered lunch :)")
  end

  def log_error(e)
    log(e)

    false
  end

  def close_driver
    log('closing driver')

    driver.close

    false
  end

  attr_reader :driver, :wait, :user, :todays_order_day
end

class ItemBlackListedError < StandardError
end
