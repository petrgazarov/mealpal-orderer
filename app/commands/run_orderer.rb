require 'clockwork'
require './config/boot'
require './config/environment'
require 'tzinfo'

module Clockwork
  RETRY_ATTEMPTS = 3

  handler do |job|
    puts "Running #{job}"
  end

  every(1.day, 'Order mealpal', tz: 'America/New_York', at: '23:02') do
    return if tomorrow_is_weekend?

    clean_up_events_table_if_too_big

    today = (TZInfo::Timezone.get('America/New_York').now.wday + 1)

    User.all.each do |user|
      todays_order_day = user.order_days.find { |od| od.week_day_number == today }

      order_for_user(user, todays_order_day)
    end
  end

  private

  def self.tomorrow_is_weekend?
    [5, 6].include?(TZInfo::Timezone.get('America/New_York').now.wday)
  end

  def self.order_for_user(user, todays_order_day)
    return unless todays_order_day.scheduled_to_order

    RETRY_ATTEMPTS.times do
      begin
        # remove PhantomJS cookies
        system 'rm $HOME/.local/share/Ofi\ Labs/PhantomJS/*'

        break if Orderer.run(user: user, todays_order_day: todays_order_day)

      rescue Exception => e
        user.events.create!(details: e.message)

        log_entry = "\n===========================\n#{Time.now}\n#{e.message}"
        File.open('log/log.log', 'a') { |file| file << log_entry }
      end
    end
  end

  def self.clean_up_events_table_if_too_big
    if ::Event.count > 9000
      ::Event.find(:all, order: 'created_at desc', limit: 1000).destroy_all
    end
  end
end
