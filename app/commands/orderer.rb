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
      log("Starting to order for #{user.mealpal_email}")

      # remove watir cookies
      delete_cookies

      visit_login_page

      login

      raise 'Kitchen closed' if kitchen_closed?

      rate_meal if rate_meal_required?

      raise 'Maximum number of meals used' if maximum_number_of_meals_used?

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
    driver.goto "https://mealpal.com/login"

    wait.until { driver.text.include? "Log in to your MealPal account" }
  end

  def login
    driver.text_field(:name, "email").when_present.set(user.mealpal_email)
    driver.text_field(:name, "password").set(user.mealpal_password)

    driver.button(:text, "Log in").click

    wait.until { driver.text.include? "Favorites" }
  end

  def meal_reserved?
    driver.text.include? 'Your meal is reserved'
  end

  def kitchen_closed?
    driver.text.include? 'The kitchen is closed'
  end

  def maximum_number_of_meals_used?
    driver.text.include? 'You have reserved your maximum number of meals'
  end

  def rate_meal_required?
    driver.text.include? 'Rate your meal!'
  end

  def rate_meal
    # rate as a "4" (good)
    driver.spans(class_name: 'star')[3].click
    # rate as a medium size portion
    driver.spans(class_name: 'portion ng-scope')[1].click

    driver.span(:text, "SUBMIT").click
  end

  def enter_address
    driver
      .text_field { input(:placeholder => 'Search by location') }
      .set(user.address)

    driver.send_keys :enter
  end

  def select_meal
    wait.until { driver.spans(:css, '.meal').length && driver.spans(:css, '.meal').length > 0 }
    sleep 15

    num_choices = driver.spans(:css, '.meal').length
    num_choices = 20 if num_choices > 20

    picked_choice_num = picked_choice_num_from_whitelist(num_choices)


    begin
      picked_choice_num = (0...num_choices).to_a.sample unless picked_choice_num

      meal_name, restaurant_name = meal_name_and_restaurant_name(picked_choice_num)

      if blacklist_includes_item?(meal_name, restaurant_name)
        log "item #{meal_name} in #{restaurant_name} restaurant blacklisted."

        raise ItemBlackListedError.new
      end

      finish_selection(picked_choice_num)

      create_ordered_item(
        name: meal_name,
        restaurant_name: restaurant_name
      )

    rescue ItemBlackListedError
      picked_choice_num = nil

      retry
    end
  end

  def picked_choice_num_from_whitelist(num_choices)
    return nil if todays_order_day.whitelist.empty?

    (0...num_choices).to_a.shuffle.each do |choice_num|
      if whitelist_includes_item?(choice_num)
        return choice_num
      end
    end

    nil
  end

  def whitelist_includes_item?(choice_num)
    meal_name, restaurant_name = meal_name_and_restaurant_name(choice_num)

    todays_order_day
      .whitelist
      .split(', ')
      .any? { |item| (meal_name + restaurant_name).downcase.include?(item.downcase) }
  end

  def blacklist_includes_item?(meal_name, restaurant_name)
    todays_order_day
      .blacklist
      .split(', ')
      .any? { |item| (meal_name + restaurant_name).downcase.include?(item.downcase) }
  end

  def meal_name_and_restaurant_name(choice_num)
    meal_name =
      driver
        .spans(:css, '.meal')[choice_num]
        .img.attribute_value('alt')

    restaurant_name =
      driver
        .spans(:css, '.meal')[choice_num]
        .div(:css, '.restaurant')
        .div(:css, '.name')
        .text

    [meal_name, restaurant_name]
  end

  def finish_selection(picked_choice_num)
    driver
      .spans(:css, '.meal')[picked_choice_num]
      .div(:css, '.image').click

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
  end

  def log(message)
    create_event_for_user(message)

    log_entry = "\n===========================\n#{Time.zone.now}\nuser_id: #{user.id}\n#{message}"
    File.open('log/log.log', 'a') { |file| file << log_entry }
  end

  def create_event_for_user(message)
    user.events.create!(details: message)
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
